class Post

  include DataMapper::Resource

  property :id,         Serial
  property :body,       Text
  property :created_at, DateTime

  belongs_to :person

  has n, :post_tags
  has n, :tags, :through => :post_tags

  def tag_list
    tags.all.map { |t| t.name }.join(', ')
  end

  def tag_list=(list)
    list.gsub(',', ' ').strip.split(' ').each do |tag|
      tags << Tag.first_or_create(:name => tag)
    end
  end

end