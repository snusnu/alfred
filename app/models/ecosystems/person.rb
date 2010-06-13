class Person

  include DataMapper::Resource

  property :id,            Serial

  property :github_name,  String, :required => true, :unique => true
  property :name,         String
  property :company,      String
  property :email,        String
  property :twitter_name, String
  property :irc_name,     String
  property :location,     String
  property :blog,         String, :length => 255

  property :created_at,   DateTime

  has n, :involvements

  has n, :projects,
    :through => :involvements

  has n, :posts
  has n, :personal_posts, 'Post', :personal => true

  has n, :votes

  has n, :voted_posts, 'Post',
    :through => :votes,
    :via => :post


  def commit_count
    involvements.sum(:commit_count, :commit_count.gt => 0, :kind => 'contributor')
  end

  def has_personal_posts?
    !personal_posts.empty?
  end

  def tweets?
    !twitter_name.nil?
  end

end
