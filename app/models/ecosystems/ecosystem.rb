class Ecosystem

  include DataMapper::Resource

  property :id,          Serial

  property :name,        String, :required => true, :unique => true, :unique_index => true
  property :description, Text

  has n, :ecosystem_projects
  has n, :projects, :through => :ecosystem_projects

  has n, :ecosystem_members
  has n, :members, 'User',
    :through => :ecosystem_members,
    :via => :user

  has n, :ecosystem_roles
  has n, :roles, :through => :ecosystem_roles
  has n, :team_members, 'User',
    :through => :ecosystem_roles,
    :via => :user

  def self.stats(name, page = 1, page_size = 60)
    start = (page.to_i - 1) * page_size.to_i
    stop  = page.to_i * (page_size.to_i - 1)
    User.all(:'involvements.commit_count'.gt => 0).map do |user|
      [user.github_name, user.commit_count]
    end.sort! { |x,y| x[1] <=> y[1] }.reverse!.slice(start..stop)
  end

  def self.committers
    User.all(:'involvements.commit_count'.gt => 0)
  end

end
