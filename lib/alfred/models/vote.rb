class Vote

  include DataMapper::Resource

  property :id,         Serial

  # store an infinite number of votes per person
  # so that votes can be corrected if necessary
  # this is why the properties below can't be keys

  property :post_id,    Integer, :nullable => false
  property :person_id,  Integer, :nullable => false

  property :impact,     Integer, :nullable => false

  property :created_at, UTCDateTime

  belongs_to :post
  belongs_to :person

end
