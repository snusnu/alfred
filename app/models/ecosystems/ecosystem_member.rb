class EcosystemMember

  include DataMapper::Resource

  belongs_to :ecosystem, :key => true
  belongs_to :person,    :key => true

end
