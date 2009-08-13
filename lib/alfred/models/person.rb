class Person

  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false, :unique => true, :unique_index => true

  property :twitter_name, String
  property :gravatar,     URI

  property :created_at,   UTCDateTime

  has n, :posts
  has n, :votes
  has n, :voted_posts, 'Post', :through => :votes, :via => :post

  def tweets?
    !self.twitter_name.nil?
  end

end
