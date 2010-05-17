class Project
  
  include DataMapper::Resource
  
  property :id,            Serial

  property :github_url,    String, :length => 255, :required => true, :unique => true, :unique_index => true

  property :homepage,      URI
  property :documentation, URI
  property :issues,        URI
  property :mailing_list,  URI
  property :twitter,       String, :length => (0..255)

  is :localizable do

    property :description,     Text

  end


  belongs_to :parent, self, :required => false

  has n, :forks, self, :child_key => [:parent_id]

  has n, :ecosystem_projects
  has n, :ecosystems, :through => :ecosystem_projects

  has n, :project_categories
  has n, :categories, 'Tag', :through => :project_categories, :via => :tag

  has n, :project_tags
  has n, :tags, :through => :project_tags


  has n, :involvements

  has n, :members, 'User',
    :through => :involvements,
    :via     => :user

  has n, :project_channels

  has n, :irc_channels,
    :through => :project_channels


  accepts_nested_attributes_for :irc_channels


  def name
    @name ||= github_url.to_s.split('/').last
  end

  def fork?
    !self.parent.nil?
  end

  def has_forks?
    !forks.empty?
  end

end
