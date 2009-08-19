require 'md5'

class Person

  include DataMapper::Resource

  property :id,            Serial
  property :name,          String, :nullable => false, :unique => true, :unique_index => true

  property :twitter_login, String
  property :github_name,   String
  property :email_address, String
  property :gravatar,      Boolean, :nullable => false, :default => false

  property :created_at,    UTCDateTime


  has n, :posts

  has n, :votes

  has n, :voted_posts, 'Post',
    :through => :votes,
    :via => :post


  def tweets?
    !self.twitter_name.nil?
  end

  def has_gravatar?
    !self.email_address.nil? && self.gravatar
  end

  def gravatar_hash
    MD5::md5(self.email_address)
  end

end
