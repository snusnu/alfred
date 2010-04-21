class Person

  include DataMapper::Resource

  property :id,            Serial
  property :name,          String, :required => true, :unique => true, :unique_index => true

  property :real_name,     String
  property :twitter_name,  String
  property :github_name,   String
  property :email_address, String

  property :created_at,    UTCDateTime


  has n, :posts
  has n, :personal_posts, 'Post', :personal => true

  has n, :votes

  has n, :voted_posts, 'Post',
    :through => :votes,
    :via => :post


  def has_personal_posts?
    !personal_posts.empty?
  end

  def tweets?
    !twitter_name.nil?
  end

  def gravatar_hash
    # default to pseudo email(s) to display distinct monster ids
    MD5::md5(email_address ? email_address : "alfred+#{name}@snusnu.info")
  end

end
