desc "Import the specified github account (default to datamapper)"
task :import => :load_env do

  DataMapper.auto_migrate! if ENV['AUTOMIGRATE']

  Language.first_or_create(:code => 'en-US', :name => 'English')
  Language.first_or_create(:code => 'de-DE', :name => 'Deutsch')

  InvolvementKind.first_or_create(:name => 'collaborator')
  InvolvementKind.first_or_create(:name => 'contributor')
  InvolvementKind.first_or_create(:name => 'forker')
  InvolvementKind.first_or_create(:name => 'watcher')

  core       = Role.first_or_create(:name => 'core')
  evangelist = Role.first_or_create(:name => 'evangelist')

  Github.import(Config['ecosystem'])

  ecosystem  = Ecosystem.first(:name => Config['ecosystem']['name'])

  dkubb      = Person.first(:github_name => 'dkubb')
  snusnu     = Person.first(:github_name => 'snusnu')
  knowtheory = Person.first(:github_name => 'knowtheory')

  EcosystemRole.create(:ecosystem => ecosystem, :user => dkubb,      :role => core)
  EcosystemRole.create(:ecosystem => ecosystem, :user => snusnu,     :role => core)
  EcosystemRole.create(:ecosystem => ecosystem, :user => knowtheory, :role => evangelist)

end


desc "Generate and seed the database"
task :seed => :automigrate do

  bot = Config['irc']['nick']

  # channel about alfred himself, also used for initial seed data

  irc_channel = IrcChannel.create(
    :server => 'irc.freenode.net',
    :channel => 'alfredbutler',
    :logged => false
  )

  tip          = PostType.create :name => 'tip'
  question     = PostType.create :name => 'question'
  reply        = PostType.create :name => 'reply'
  note         = PostType.create :name => 'note'
  conversation = PostType.create :name => 'conversation'

end
