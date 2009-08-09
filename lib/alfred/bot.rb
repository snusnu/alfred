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

on :channel, /^#{Config['irc']['nick']}.* post\[(.*)\]: (.*)/ do |tags, example|
  post_id = RestClient.post("#{Config.service_url}/posts", :from => nick, :body => example, :tags => tags)
  reply = "thx #{nick}, stored your post at #{Config.service_url}/posts/#{post_id} and tagged it with '#{tags}'"
  msg channel, reply
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
