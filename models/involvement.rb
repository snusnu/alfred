class Involvement
  
  include DataMapper::Resource

  property :commit_count, Integer, :required => true, :default => 0, :min => 0

  belongs_to :project,          :key => true
  belongs_to :user,             :key => true
  belongs_to :involvement_kind, :key => true, :child_key => [:kind], :parent_key => [:name]


  def self.nr_of_forkers
    all(:fields => [ :user_id ], :kind => 'forker').map(&:user_id).uniq.size
  end

  def self.nr_of_watchers
    all(:fields => [ :user_id ], :kind => 'watcher').map(&:user_id).uniq.size
  end

  def self.nr_of_collaborators
    all(:fields => [ :user_id ], :kind => 'collaborator').map(&:user_id).uniq.size
  end

  def self.nr_of_contributors
    all(:fields => [ :user_id ], :kind => 'contributor').map(&:user_id).uniq.size
  end


  def self.forkers
    all_of_kind('forker')
  end

  def self.watchers
    all_of_kind('watcher')
  end

  def self.collaborators
    all_of_kind('collaborator')
  end

  def self.contributors
    all_of_kind('contributor')
  end

  def self.all_of_kind(kind)
    all(:fields => [ :user_id ], :kind => kind, :unique => true).size
  end

end
