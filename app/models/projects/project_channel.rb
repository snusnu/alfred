class ProjectChannel

  include DataMapper::Resource

  belongs_to :project,     :key => true
  belongs_to :irc_channel, :key => true

end
