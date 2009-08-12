class Person

  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false
  property :twitter_name, String

  property :created_at,   UTCDateTime

  has n, :posts

  def tweets?
    !self.twitter_name.nil?
  end

end
