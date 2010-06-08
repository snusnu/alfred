class Ecosystem

  include DataMapper::Resource

  property :id,          Serial

  property :name,        String, :required => true, :unique => true
  property :description, Text

  has n, :ecosystem_projects
  has n, :projects, :through => :ecosystem_projects

  has n, :ecosystem_members
  has n, :members, 'Person',
    :through => :ecosystem_members,
    :via => :person

  has n, :ecosystem_roles
  has n, :roles, :through => :ecosystem_roles
  has n, :team_members, 'Person',
    :through => :ecosystem_roles,
    :via => :person

  def self.stats(name, page = 1, page_size = 60)
    start = (page.to_i - 1) * page_size.to_i
    stop  = page.to_i * (page_size.to_i - 1)
    Person.all(:'involvements.commit_count'.gt => 0).map do |person|
      [person.github_name, person.commit_count]
    end.sort! { |x,y| x[1] <=> y[1] }.reverse!.slice(start..stop)
  end

  def self.committers
    Person.all(:'involvements.commit_count'.gt => 0)
  end

end
