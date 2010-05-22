class IrcChannel

  include DataMapper::Resource

  property :id,         Serial

  property :server,     String,  :required => true, :unique_index => :unique_channels
  property :channel,    String,  :required => true, :unique_index => :unique_channels
  property :logged,     Boolean, :required => true, :default => false

  property :created_at, UTCDateTime

  has n, :posts

  validates_uniqueness_of :channel, :scope => [ :server ]


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
