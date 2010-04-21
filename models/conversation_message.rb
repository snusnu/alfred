class ConversationMessage

  include DataMapper::Resource

  property :id, Serial

  property :timestamp, Integer, :required => true
  property :body,      String,  :required => true, :length => 1024
  
  belongs_to :conversation
  belongs_to :person


  def permalink
    Alfred::Utils.remote_permalink(conversation.irc_channel, timestamp)
  end

end
