class PostTag

  include DataMapper::Resource

  belongs_to :post, :key => true
  belongs_to :tag,  :key => true

end
