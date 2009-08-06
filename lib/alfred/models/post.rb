class Post

  include DataMapper::Resource

  property :id,         Serial
  property :body,       Text
  property :created_at, DateTime

  belongs_to :person

  is :taggable

end