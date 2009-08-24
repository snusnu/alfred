require 'rubygems'
require 'isaac'
require 'rest_client'
require 'json'

require 'lib/utils'
require 'lib/twitter'
require 'lib/config'

Config.load_config(File.dirname(__FILE__) + '/config.yml')

configure do |c|
  c.nick     = Config['irc']['nick']
  c.server   = Config['irc']['server']
  c.port     = Config['irc']['port'] || 6667
  c.realname = Config['irc']['realname']
  c.verbose  = Config['irc']['verbose']
  c.version  = '0.0.1'
end


# ------------------------------ HELPERS ---------------------------------


helpers do

  def handle_tip(channel, nick, body, tags, via)
    post = create_post(channel, 'tip', nick, body, tags, via)
    msg channel, "thx #{nick}, stored your tip at #{Config.service_url}/posts/#{post['id']} and tagged it with '#{tags}'"
  end

  def handle_question(channel, nick, body, tags, via)
    post = create_post(channel, 'question', nick, body, tags, via)
    msg channel, "thx #{nick}, stored your question at #{Config.service_url}/posts/#{post['id']} and tagged it with '#{tags}'"
  end

  def handle_reply(channel, nick, body, referrer_ids)
    referrers = referrer_ids.gsub(',', ' ').split(' ').uniq.join(',')
    post = create_post(channel, 'reply', nick, body, nil, nil, nil, nil, nil, referrers)
    msg channel, "thx #{nick}, stored your reply at #{Config.service_url}/posts/#{post['id']}"
  end


  def handle_note(channel, nick, body, tags, via, personal = false)
    post = create_post(channel, 'note', nick, body, tags, via, nil, nil, nil, nil, personal)
    reply_target = personal ? nick : channel
    msg reply_target, "thx #{nick}, stored your note at #{Config.service_url}/posts/#{post['id']} and tagged it with '#{tags}'"
  end

  def handle_conversation(channel, nick, body, tags, start, stop, people, personal = false)
    reply_target = personal ? nick : channel
    if Alfred::Utils.logged_channel?(channel)
      post = create_post(channel, 'conversation', nick, body, tags, nil, start, stop, people, nil, personal)
      msg reply_target, "thx #{nick}, remembered the conversation at #{Config.service_url}/posts/#{post['id']} and tagged it with '#{tags}'"
    else
      msg reply_target, "sorry #{nick}, can't remember that conversation because this channel isn't currently logged by irclogger.com"
    end
  end


  def create_post(channel, type, person, body, tags, via = nil, start = nil, stop = nil, people = nil, referrers = nil, personal = false)
    params = { :channel => channel, :type => type, :person => person, :body => body, :personal => personal }
    # nil value gets posted as empty string apparently
    params[:tags      ] = tags      if tags
    params[:via       ] = via       if via
    params[:start     ] = start     if start
    params[:stop      ] = stop      if stop
    params[:people    ] = people    if people
    params[:referrers ] = referrers if referrers
    JSON.parse(RestClient.post("#{Config.service_url}/posts", params))
  end

  def ensure_permissions
    halt unless Config.allowed?(nick)
  end

end


# ------------------------------- BASICS ---------------------------------


on :connect do
  Config['irc']['channels'].each do |channel|
    join "##{channel}"
    msg 'nickserv', "identify #{Config['irc']['nickserv']}"
  end
end

on :error, 401 do
  puts "oops, seems like #{nick} isn't around."
end

on :channel, /^#{Config['irc']['nick']}.* identify/ do
  msg channel, "#{nick}: #{Config['irc']['realname']}, version #{Config['irc']['version']} at your service"
end

on :channel, /^#{Config['irc']['nick']}.* what is the answer to life, the universe, and everything/ do
  msg channel, "#{nick}: 42"
end


# ------------------------------ POST STUFF ---------------------------------


# Use http://rubular.com to inspect these (especially to get at the match group ordering)

TIP          = /^(#{Config['irc']['nick']})?.*tip\s*\[([^\]]+)\]\s*(\(via ([^\)]+)\)?)?(:,\,)? (.*)\z/
NOTE         = /^(#{Config['irc']['nick']})?.*note\s*\[([^\]]+)\]\s*(\(via ([^\)]+)\)?)?(:,\,)? (.*)\z/
QUESTION     = /^(#{Config['irc']['nick']})?.*ask\s*\[([^\]]+)\]\s*(\(via ([^\)]+)\)?)?(:,\,)? (.*)\z/
REPLY        = /^(#{Config['irc']['nick']})?.*(answer|reply)\s*\[(.+?)\](:,\,)? (.*)\z/
CONVERSATION = /^(#{Config['irc']['nick']})?.*remember from (\-\d+) to (\-\d+|now)\s*\[([^\]]+)\]\s*(\(([^\)]+)\)?)?(:,\,)? (.*)\z/
VOTE         = /^(#{Config['irc']['nick']})?.*(\+|\-)1 for (post|note|tip|question|answer|reply) (.*)\z/

on :channel, TIP do |_, tags, _, via, _, body|
  handle_tip(channel, nick, body, tags, via)
end

on :channel, QUESTION do |_, tags, _, via, _, body|
  handle_question(channel, nick, body, tags, via)
end

on :channel, REPLY do |_, _, referrer_ids, _, body|
  handle_reply(channel, nick, body, referrer_ids)
end

on :channel, VOTE do |_, impact, post_type, post_id|
  begin
    url = "#{Config.service_url}/votes"
    post = JSON.parse(RestClient.post(url, :person => nick, :post_id => post_id, :impact => impact))
    vote_stats = "(#{post['vote_count']}/#{post['vote_sum']})"
    msg channel, "thx #{nick}, stored your vote at #{Config.service_url}/posts/#{post['id']}, current vote stats: #{vote_stats}"
  rescue RestClient::ResourceNotFound
    msg channel, "sorry #{nick}, there is no post with ID = #{post_id}"
  end
end


on :channel, NOTE do |_, tags, _, via, _, body|
  handle_note(channel, nick, body, tags, via)
end

on :channel, CONVERSATION do |_, start, stop, tags, _, people, _, body|
  handle_conversation(channel, nick, body, tags, start, stop, people)
end


on :private, NOTE do |_, tags, _, via, _, body|
  handle_note(channel, nick, body, tags, via, true)
end

on :private, CONVERSATION do |_, start, stop, tags, _, people, _, body|
  handle_conversation(channel, nick, body, tags, start, stop, people, true)
end


# ------------------------- SITE NAVIGATION ---------------------------------


on :channel, /^#{Config['irc']['nick']}.* show commands$/ do
  msg channel, "#{nick}: #{Config.service_url}/commands"
end

on :channel, /^#{Config['irc']['nick']}.* show posts$/ do
  msg channel, "#{nick}: #{Config.service_url}/posts"
end

on :channel, /^#{Config['irc']['nick']}.* show tips$/ do
  msg channel, "#{nick}: #{Config.service_url}/posts?type=tip"
end

on :channel, /^#{Config['irc']['nick']}.* show questions/ do
  msg channel, "#{nick}: #{Config.service_url}/posts?type=question"
end

on :channel, /^#{Config['irc']['nick']}.* show answers/ do
  msg channel, "#{nick}: #{Config.service_url}/posts?type=reply"
end

on :channel, /^#{Config['irc']['nick']}.* show notes/ do
  msg channel, "#{nick}: #{Config.service_url}/posts?type=note"
end

on :channel, /^#{Config['irc']['nick']}.* show tags$/ do
  msg channel, "#{nick}: #{Config.service_url}/tags"
end

on :channel, /^#{Config['irc']['nick']}.* show posts tagged with (.*)$/ do |tags|
  tags = tags.gsub(',', ' ').split(' ').uniq.join(',')
  msg channel, "#{nick}: #{Config.service_url}/posts?tags=#{tags}"
end

on :channel, /^#{Config['irc']['nick']}.* show (question|post|answer|reply) (.*)/ do |_,post_id|
  begin
    RestClient.get("#{Config.service_url}/posts/#{post_id}")
    msg channel, "#{nick}: #{Config.service_url}/posts/#{post_id}"
  rescue RestClient::ResourceNotFound
    msg channel, "sorry #{nick}, there is no post with ID = #{post_id}"
  end
end

# ------------------------------- PROFILE ---------------------------------

on :private, /^register$/ do
  url = "#{Config.service_url}/people"
  RestClient.post(url, :name => nick)
  msg nick, "thx #{nick}, created your profile on the website"
end

on :private, /^register github name: (\S+)/ do |github_name|
  url = "#{Config.service_url}/people/#{nick}"
  RestClient.put(url, :github_name => github_name)
  msg nick, "thx #{nick}, stored your github name in your profile"
end

on :private, /^register twitter name: (\S+)/ do |twitter_name|
  url = "#{Config.service_url}/people/#{nick}"
  RestClient.put(url, :twitter_name => twitter_name)
  msg nick, "thx #{nick}, stored your twitter name in your profile"
end

on :private, /^register email: (\S+)/ do |email|
  url = "#{Config.service_url}/people/#{nick}"
  RestClient.put(url, :email_address => email)
  msg nick, "thx #{nick}, stored your email address in your profile"
end


# ------------------------- TWITTER (thx nancie) ---------------------------------


on :channel, /^#{Config['irc']['nick']}.* tweet: (.*)/ do
  ensure_permissions
  reply = Alfred::Twitter.tweet(Config.twitter_owner_credentials, match[0])
  msg channel, "#{nick}: you tweeted #{Alfred::Twitter.status_url(Config.twitter_owner_login, reply['id'])}"
end

on :channel, /^#{Config['irc']['nick']}.* follow (\S+)/ do
  ensure_permissions
  begin
    user = match[0]
    reply = Alfred::Twitter.follow(Config.twitter_owner_credentials, user)
    msg channel, "#{Config.twitter_owner_login} is now following #{reply['screen_name']}."
  rescue
    msg channel, "#{nick}: something went wrong as I tried to follow #{user}."
  end
end

on :private, /^allow (\S+)/ do
  ensure_permissions
  user = match[0]
  Config.allow!(user)
  msg nick, "#{nick}: you just allowed #{user} to use me to tweet in the name of #{Config.twitter_owner_login}"
end
