class Conversation

  include DataMapper::Resource

  property :id,         Serial
  property :post_id,    Integer, :nullable => false, :unique => true, :unique_index => true

  property :start,      UTCDateTime
  property :stop,       UTCDateTime

  property :created_at, UTCDateTime


  belongs_to :post

  has n, :people, :through => Resource

  has n, :tags,
    :through => :post,
    :via     => :tags


  def start=(d)
    attribute_set(:start, Time.now - (Integer(d).abs * 60))
  end

  def stop=(d)
    if d == 'now'
      attribute_set(:stop, Time.now)
    else
      attribute_set(:stop, Time.now - (Integer(d).abs * 60))
    end
  end

end
