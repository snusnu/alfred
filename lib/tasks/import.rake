desc "Import the specified github account (default to datamapper)"
task :import => :environment do

  DataMapper.auto_migrate! if ENV['AUTOMIGRATE']

  DataMapper::I18n::Locale.first_or_create(:tag => 'en-US', :name => 'English')
  DataMapper::I18n::Locale.first_or_create(:tag => 'de-DE', :name => 'Deutsch')

  InvolvementKind.first_or_create(:name => 'collaborator')
  InvolvementKind.first_or_create(:name => 'contributor')
  InvolvementKind.first_or_create(:name => 'forker')
  InvolvementKind.first_or_create(:name => 'watcher')

  core       = Role.first_or_create(:name => 'core')
  evangelist = Role.first_or_create(:name => 'evangelist')

  Github.import(Alfred.config['ecosystem'])

  ecosystem  = Ecosystem.first(:name => Alfred.config['ecosystem']['name'])

  dkubb      = Person.first(:github_name => 'dkubb')
  snusnu     = Person.first(:github_name => 'snusnu')
  knowtheory = Person.first(:github_name => 'knowtheory')

  EcosystemRole.create(:ecosystem => ecosystem, :person => dkubb,      :role => core)
  EcosystemRole.create(:ecosystem => ecosystem, :person => snusnu,     :role => core)
  EcosystemRole.create(:ecosystem => ecosystem, :person => knowtheory, :role => evangelist)

end


desc "Generate and seed the database"
task :seed => 'db:automigrate' do

  bot = Alfred.config['irc']['nick']

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
