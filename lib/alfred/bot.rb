require 'rubygems'
require 'isaac'
require 'rest_client'
require 'json'
require 'twitter'

require 'config'

Config.load_config(File.dirname(__FILE__) + '/config.yml')

configure do |c|
  c.nick     = Config['irc']['nick']
  c.server   = Config['irc']['server']
  c.port     = Config['irc']['port'] || 6667
  c.realname = Config['irc']['realname']
  c.verbose  = Config['irc']['verbose']
  c.version  = '0.0.1'
end


# ------------------------------ ALFRED ---------------------------------

on :connect do
  join "##{Config['irc']['channel']}"
  msg 'nickserv', "identify #{Config['irc']['nickserv']}"
end

on :channel, /^#{Config['irc']['nick']}.* identify/ do
  msg channel, "#{nick}: #{Config['irc']['realname']}, version #{Config['irc']['version']} at your service"
end

on :channel, /^#{Config['irc']['nick']}.* show posts/ do
  msg channel, "#{nick}: #{Config.service_url}/posts"
end

on :channel, /^#{Config['irc']['nick']}.* show commands/ do
  msg channel, "#{nick}: #{Config.service_url}/commands"
end

on :channel, /^#{Config['irc']['nick']}.* show tags/ do
  msg channel, "#{nick}: #{Config.service_url}/tags"
end

on :channel, /^#{Config['irc']['nick']}.* show tag(s)? (.*)$/ do |_, tags|
  msg channel, "#{nick}: #{Config.service_url}/posts?tags=#{tags}"
end


on :channel, /^#{Config['irc']['nick']}.* show questions/ do
  msg channel, "#{nick}: #{Config.service_url}/questions"
end

on :channel, /^#{Config['irc']['nick']}.* show (question|post|answer) (.*)/ do |_,post_id|
  begin
    RestClient.get("#{Config.service_url}/posts/#{post_id}")
    msg channel, "#{nick}: #{Config.service_url}/posts/#{post_id}"
  rescue RestClient::ResourceNotFound
    msg channel, "sorry #{nick}, there is no post with ID = #{post_id}"
  end
end

on :channel, /^#{Config['irc']['nick']}.* show answers/ do
  msg channel, "#{nick}: #{Config.service_url}/answers"
end

on :channel, /^#{Config['irc']['nick']}.* post\[(.*)\]: (.*)/ do |tags, example|
  post_id = RestClient.post("#{Config.service_url}/posts", :from => nick, :body => example, :tags => tags)
  reply = "thx #{nick}, stored your post at #{Config.service_url}/posts/#{post_id} and tagged it with '#{tags}'"
  msg channel, reply
end

on :channel, /^#{Config['irc']['nick']}.* ask\[(.*)\]: (.*)/ do |tags, question|
  post_id = RestClient.post("#{Config.service_url}/questions", :from => nick, :body => question, :tags => tags)
  reply = "thx #{nick}, stored your question at #{Config.service_url}/questions/#{post_id} and tagged it with '#{tags}'"
  msg channel, reply
end

on :channel, /^#{Config['irc']['nick']}.* answer\[(.*)\]: (.*)/ do |ids, answer|
  post_ids = RestClient.post("#{Config.service_url}/answers?questions=#{ids}", :from => nick, :body => answer)
  link_list = post_ids.split(',').inject([]) do |links, post_id|
    links << "#{Config.service_url}/questions/#{post_id}"
  end
  answer_word   = link_list.size > 1 ? 'answers'   : 'answer'
  question_word = link_list.size > 1 ? 'questions' : 'question'
  reply = "thx #{nick}, stored your #{answer_word} to the following #{question_word}: #{link_list.join(' and ')}"
  msg channel, reply
end

on :channel, /^#{Config['irc']['nick']}.* (\+|\-)1 for (post|question|answer) (.*)/ do |impact, post_type, post_id|
  begin
    vote_action = impact == '+' ? 'up' : 'down'
    RestClient.post("#{Config.service_url}/posts/#{post_id}/vote/#{vote_action}", :from => nick)
    reply = "thx #{nick}, stored your vote at #{Config.service_url}/posts/#{post_id}"
    msg channel, reply
  rescue RestClient::ResourceNotFound
    msg channel, "sorry #{nick}, there is no post with ID = #{post_id}"
  end
end

on :error, 401 do
  puts "oops, seems like #{nick} isn't around."
end


# ------------------------------ NANCIE ---------------------------------


helpers do

  def ensure_permissions
    halt unless Config.allowed?(nick)
  end

end

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

on :channel, /^#{Config['irc']['nick']}.* what is the answer to life, the universe, and everything/ do
  msg channel, "#{nick}: 42"
end
