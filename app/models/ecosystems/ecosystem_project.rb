class EcosystemProject

  include DataMapper::Resource

  belongs_to :ecosystem, :key => true
  belongs_to :project,   :key => true

end
