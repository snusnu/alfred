require 'utils'

class Post

  include DataMapper::Resource

  property :id,            Serial
  property :person_id,     Integer, :nullable => false
  property :post_type_id,  Integer, :nullable => false

  # denormalized for performance reasons
  property :vote_sum,      Integer, :nullable => false, :default => 0
  property :vote_count,    Integer, :nullable => false, :default => 0, :min => 0

  property :body,          Text,    :nullable => false

  property :created_at,    UTCDateTime


  belongs_to :person
  belongs_to :post_type

  has n, :votes

  has n, :post_tags

  has n, :tags,
    :through => :post_tags


  is :self_referential, :through => 'FollowUpPost',
    :parents  => :referrers,
    :children => :follow_ups


  def reply?
    referrers.all.size > 0
  end

  def has_follow_ups?
    follow_ups.all.size > 0
  end

  def tag_list
    tags.all.map { |t| t.name }.join(', ')
  end

  def tag_list=(list)
    Alfred::Utils.tag_list(list).each do |tag|
      tags << Tag.first_or_create(:name => tag)
    end
  end

  def vote(person, impact)

    # silently ignore errors for now
    return unless person = Person.first(:name => person)
    return if Vote.first(:post => self, :person => person)

    impact = case impact
    when '+' then  1
    when '-' then -1
    else
      return # silently do nothing
    end

    Vote.create(:post => self, :person => person, :impact => impact)
    self.vote_sum   += impact
    self.vote_count += 1
    save

  end
end
