class InvolvementKind

  include DataMapper::Resource

  property :name,        String, :key => true
  property :description, Text

end
