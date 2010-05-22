class EcosystemMember

  include DataMapper::Resource

  belongs_to :ecosystem, :key => true
  belongs_to :user,      :key => true

end
