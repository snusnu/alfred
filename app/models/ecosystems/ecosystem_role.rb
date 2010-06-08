class EcosystemRole

  include DataMapper::Resource

  belongs_to :ecosystem, :key => true
  belongs_to :person,    :key => true
  belongs_to :role,      :key => true

end
