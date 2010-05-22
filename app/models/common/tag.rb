class Tag

  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :required => true, :unique => true, :unique_index => true

  has n, :post_tags
  has n, :posts, :through => :post_tags

end
