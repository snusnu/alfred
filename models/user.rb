class User
  
  include DataMapper::Resource
  
  property :id,           Serial
  
  property :github_name,  String, :unique => true, :unique_index => true
  property :name,         String
  property :company,      String
  property :location,     String
  property :blog,         String, :length => 255
  property :email,        String
  property :twitter_name, String
  property :irc_name,     String
  
  property :since,        DateTime


  has n, :involvements

  has n, :projects,
    :through => :involvements


  def commit_count
    involvements.sum(:commit_count, :commit_count.gt => 0, :kind => 'contributor')
  end

  def has_personal_posts?
    false
  end

  def tweets?
    !twitter_name.nil?
  end

end
