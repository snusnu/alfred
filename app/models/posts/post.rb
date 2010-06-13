class Post

  include DataMapper::Resource

  property :id,            Serial

  # denormalized for performance reasons
  property :vote_sum,      Integer, :required => true, :default => 0
  property :vote_count,    Integer, :required => true, :default => 0, :min => 0

  property :body,          Text,    :required => true
  property :personal,      Boolean, :required => true, :default => false

  property :timestamp,     Integer # optional irclogger backlink anchor

  property :created_at,    DateTime

  belongs_to :irc_channel
  belongs_to :post_type
  belongs_to :person
  belongs_to :via, 'Person', :required => false

  has n, :votes

  has n, :post_tags

  has n, :tags,
    :through => :post_tags

  has 0..1, :conversation


  is :self_referential, :through => 'FollowUpPost',
    :parents  => :referrers,
    :children => :follow_ups


  def permalink
    return conversation.permalink if conversation?
    timestamp ? Alfred::Utils.remote_permalink(irc_channel, timestamp) : '#'
  end

  def logged?
    irc_channel.logged?
  end

  def note?
    post_type.name == 'note'
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

  def remember
    return unless logged?
    if conversation?
      conversation.remember
    else
      Thread.new do
        remembered = false
        while !remembered # retry in case the irclogger bot hasn't registered the message yet
          remote_messages = Alfred::Utils.fetch_remote_conversation(self, created_at.to_time - 30, created_at.to_time + 5)
          remote_messages.each do |message|
            if message['nick'] == person.name && message['line'].include?(body)
              update!(:timestamp => message['timestamp'])
              remembered = true
            end
          end
          sleep 1
        end
      end
    end
  end

end
