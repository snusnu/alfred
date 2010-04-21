class Vote

  include DataMapper::Resource

  property :id,         Serial

  property :post_id,    Integer, :required => true, :unique => true, :unique_index => true
  property :person_id,  Integer, :required => true, :unique => true, :unique_index => true

  property :impact,     Integer, :required => true

  property :created_at, UTCDateTime

  belongs_to :post
  belongs_to :person

end
