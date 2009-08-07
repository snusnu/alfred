class PostTag

  include DataMapper::Resource

  property :post_id, Integer, :key => true
  property :tag_id,  Integer, :key => true

  belongs_to :post
  belongs_to :tag

end
