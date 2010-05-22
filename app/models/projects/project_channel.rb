class ProjectChannel
  
  include DataMapper::Resource
  
  property :created_at,     UTCDateTime
  property :updated_at,     UTCDateTime
  property :deleted_at,     ParanoidDateTime

  belongs_to :project, :key => true
  belongs_to :irc_channel, :key => true

end
