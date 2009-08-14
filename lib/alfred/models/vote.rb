class Vote

  include DataMapper::Resource

  property :id,         Serial

  property :post_id,    Integer, :nullable => false, :unique => true, :unique_index => true
  property :person_id,  Integer, :nullable => false, :unique => true, :unique_index => true

  property :impact,     Integer, :nullable => false

  property :created_at, UTCDateTime

  belongs_to :post
  belongs_to :person

end
