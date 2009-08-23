require 'json'
require 'restclient'

class IrcChannel

  include DataMapper::Resource

  property :id,         Serial

  property :server,     String,  :nullable => false, :unique_index => :unique_channels
  property :channel,    String,  :nullable => false, :unique_index => :unique_channels
  property :logged,     Boolean, :nullable => false, :default => false

  property :created_at, UTCDateTime

  has n, :posts

  validates_is_unique :channel, :scope => [ :server ]


  def self.channel(attributes)
    irc_channel = first(attributes)
    return irc_channel if irc_channel
    attributes[:logged] = Alfred::Utils.logged_channel?(attributes[:channel])
    create(attributes)
  end

  def raw_channel_name
    channel.gsub('#', '')
  end

end
