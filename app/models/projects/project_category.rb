class ProjectCategory

  include DataMapper::Resource

  belongs_to :project, :key => true
  belongs_to :tag,     :key => true

end
