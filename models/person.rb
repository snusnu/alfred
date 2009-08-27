class Person

  include DataMapper::Resource

  property :id,            Serial
  property :name,          String, :nullable => false, :unique => true, :unique_index => true

  property :twitter_name,  String
  property :github_name,   String
  property :email_address, String

  property :created_at,    UTCDateTime


  has n, :posts

  has n, :votes

  has n, :voted_posts, 'Post',
    :through => :votes,
    :via => :post


  def tweets?
    !twitter_name.nil?
  end

  def has_gravatar?
    !email_address.nil? && gravatar
  end

  def gravatar_hash
    MD5::md5(email_address)
  end

end
