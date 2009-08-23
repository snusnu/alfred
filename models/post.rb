require 'models/conversation'

class Post

  include DataMapper::Resource

  property :id,            Serial

  # denormalized for performance reasons
  property :vote_sum,      Integer, :nullable => false, :default => 0
  property :vote_count,    Integer, :nullable => false, :default => 0, :min => 0

  property :body,          Text,    :nullable => false

  property :created_at,    UTCDateTime

  belongs_to :irc_channel
  belongs_to :post_type
  belongs_to :person
  belongs_to :via, 'Person', :nullable => true

  has n, :votes

  has n, :post_tags

  has n, :tags,
    :through => :post_tags

  has 0..1, :conversation


  is :self_referential, :through => 'FollowUpPost',
    :parents  => :referrers,
    :children => :follow_ups


  def logged?
    irc_channel.logged?
  end

  def conversation?
    post_type.name == 'conversation'
  end

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

  def vote(person_name, increment_or_decrement)
    return unless person = Person.first(:name => person_name)
    return if votes.first(:person => person) # FIXME this always returns an empty array
    return unless %w[ + - ].include?(increment_or_decrement)

    vote = votes.create(
      :person => person,
      :impact => increment_or_decrement == '+' ? 1 : -1
    )

    update(:vote_sum => vote_sum + vote.impact, :vote_count => vote_count + 1)
  end

end
