class Commit

  include DataMapper::Resource

  property :id,      String, :key => true
  property :message, Text, :required => true

  belongs_to :project
  belongs_to :author, 'User'
  belongs_to :committer, 'User'

  has n, :parents, self

end
