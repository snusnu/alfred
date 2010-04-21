class PostType

  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :required => true, :unique => true, :unique_index => true
  property :description,  Text

  has n, :posts

end
