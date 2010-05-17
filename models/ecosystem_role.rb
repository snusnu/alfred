class EcosystemRole

  include DataMapper::Resource

  belongs_to :ecosystem, :key => true
  belongs_to :user,      :key => true
  belongs_to :role,      :key => true

end
