class Involvement
  
  include DataMapper::Resource

  property :commit_count, Integer, :required => true, :default => 0, :min => 0

  belongs_to :project,          :key => true
  belongs_to :person,           :key => true
  belongs_to :involvement_kind, :key => true, :child_key => [:kind], :parent_key => [:name]

  # works

  def self.nr_of_forkers
    all(:fields => [ :person_id ], :kind => 'forker').map(&:person_id).uniq.size
  end

  def self.nr_of_watchers
    all(:fields => [ :person_id ], :kind => 'watcher').map(&:person_id).uniq.size
  end

  def self.nr_of_collaborators
    all(:fields => [ :person_id ], :kind => 'collaborator').map(&:person_id).uniq.size
  end

  def self.nr_of_contributors
    all(:fields => [ :person_id ], :kind => 'contributor').map(&:person_id).uniq.size
  end

  # TODO doesn't work

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
    all(:fields => [ :person_id ], :kind => kind, :unique => true).size
  end

end
