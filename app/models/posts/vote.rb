class Vote

  include DataMapper::Resource

  property :id,         Serial
  property :impact,     Integer, :required => true
  property :created_at, UTCDateTime

  belongs_to :post,   :key => true
  belongs_to :person, :key => true

end
