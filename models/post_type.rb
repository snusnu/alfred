class PostType

  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false, :unique => true, :unique_index => true
  property :description,  Text

  has n, :posts

end
