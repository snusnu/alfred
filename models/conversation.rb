class Conversation

  include DataMapper::Resource

  property :id,         Serial
  property :post_id,    Integer, :nullable => false, :unique => true, :unique_index => true

  property :start,      UTCDateTime, :nullable => false
  property :stop,       UTCDateTime, :nullable => false

  property :created_at, UTCDateTime


  belongs_to :post

  has n, :people, :through => Resource

  has n, :tags,
    :through => :post,
    :via     => :tags

  has n, :messages, 'ConversationMessage'


  def start=(d)
    self[:start] = Time.now - (Integer(d).abs * 60)
  end

  def stop=(d)
    if d == 'now'
      self[:stop] = Time.now
    else
      self[:stop] = Time.now - (Integer(d).abs * 60)
    end
  end


  def irc_channel
    post.irc_channel
  end

  def permalink
    messages.first ? messages.first.permalink : '#'
  end

  def remember
    Thread.new do
      remote_messages = Alfred::Utils.fetch_remote_conversation(post, start, stop, people)
      return if remote_messages.empty?
      remote_messages.each do |message|
        messages << ConversationMessage.new(
          :person    => Person.first_or_create(:name => message['nick']),
          :timestamp => message['timestamp'],
          :body      => message['line']
        )
      end
      messages.save
    end
  end

end
