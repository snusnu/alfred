require 'rubygems'
require 'isaac' # requires 0.2 / shaft
require 'rest_client'
require 'json'

require 'config'
require 'models'

Config.load

puts "nick = #{Config['irc']['nick']}"

configure do |c|
  c.nick    = Config['irc']['nick']
  c.server  = Config['irc']['server']
  c.port    = Config['irc']['port'] || 6667
  c.verbose  = true
  c.realname = 'Alfred the IRC butler'
  c.version  = '0.0.1'
end

helpers do
  def service_url
    Config['service']['base']
  end
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
  post_id = RestClient.post("#{service_url}/posts", :from => nick, :body => example, :tags => tags)
  reply = "thx #{nick}, stored your post at #{service_url}/posts/#{post_id} and tagged it with '#{tags}'"
  msg channel, reply
end

on :channel, /^#{Config['irc']['nick']}.* show site/ do
  msg channel, "#{nick}: #{service_url}/posts"
end

on :channel, /^#{Config['irc']['nick']}.* show commands/ do
  msg channel, "#{nick}: #{service_url}/commands"
end

on :channel, /^#{Config['irc']['nick']}.* show tags/ do
  msg channel, "#{nick}: #{service_url}/tags"
end

on :channel, /^#{Config['irc']['nick']}.* show tag(s)? (.*)$/ do |_, tags|
  msg channel, "#{nick}: #{service_url}/posts?tags=#{tags}"
end

on :error, 401 do
  puts "oops, seems like #{nick} isn't around."
end


# ------------------------------ NANCIE ---------------------------------


helpers do
  def twitter(url, params={})
    JSON.parse(RestClient.post "http://#{Config.twitter_credentials}@twitter.com/" + url + ".json", params)
  end

  def ensure_permissions
    halt unless Config.allowed?(nick)
  end
end

on :channel, /^#{Config['irc']['nick']}.* tweet: (.*)/ do
  ensure_permissions
  reply = twitter "statuses/update", :status => match[0]
  msg channel, "#{nick}: you tweeted http://twitter.com/#{Config['twitter']['login']}/status/#{reply['id']}"
end

on :channel, /^#{Config['irc']['nick']}.* follow: (\S+)/ do
  ensure_permissions
  begin
    follow = match[0]
    reply = twitter "friendships/create/#{follow}"
    msg channel, "#{nick}: we're now following #{reply['screen_name']}."
  rescue
    msg channel, "#{nick}: something went wrong as I tried to follow #{follow}."
  end
end

on :private, /^allow (\S+)/ do
  puts "nick = #{nick}, allowed = #{Config.allowed?(nick)}, match[0] = #{match[0]}"
  ensure_permissions
  allow = match[0]
  Config.allow!(allow)
  msg nick, "#{nick}: you just allowed #{allow} to use me to tweet things"
end

on :channel, /^#{Config['irc']['nick']}.* what is the answer to life, the universe, and everything/ do
  msg channel, "#{nick}: 42"
end