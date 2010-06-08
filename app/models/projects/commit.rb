class Commit

  include DataMapper::Resource

  property :id,      String,   :key => true
  property :message, Text,     :required => true
  property :date,    DateTime, :required => true

  belongs_to :project
  belongs_to :author,    'Person'
  belongs_to :committer, 'Person'

  has n, :parents, self

end
