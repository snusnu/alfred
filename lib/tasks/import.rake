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

  snusnu = Person.create(
    :name => 'snusnu',
    :twitter_name  => 'gmsmon',
    :github_name   => 'snusnu',
    :email_address => 'gamsnjaga@gmail.com'
  )

  armitage = Person.create(
    :name => 'armitage',
    :twitter_name  => 'lordarmitage',
    :github_name   => 'armitage',
    :email_address => 'lord.armitage@gmail.com'
  )

  question_1 = Post.create(
    :irc_channel => irc_channel,
    :post_type   => question,
    :person      => snusnu,
    :body        => "Are we up and running?",
    :tag_list    => "alfred"
  )

  reply_1 = Post.create(
    :irc_channel => irc_channel,
    :post_type   => reply,
    :person      => snusnu,
    :body        => "Yeah, sure thing!",
    :tag_list    => "alfred"
  )

  reply_1.vote('armitage', '+')

  FollowUpPost.create(
    :source => question_1,
    :target => reply_1
  )

  question_2 = Post.create(
    :irc_channel => irc_channel,
    :post_type   => question,
    :person      => snusnu,
    :body        => "Do we have nice styles?",
    :tag_list    => "alfred"
  )

  reply_2 = Post.create(
    :irc_channel => irc_channel,
    :post_type   => reply,
    :person      => armitage,
    :body        => "Yeah, sure thing!",
    :tag_list    => "alfred"
  )

  reply_2.vote('snusnu', '+')

  FollowUpPost.create(
    :source => question_2,
    :target => reply_2
  )

  tip_1 = Post.create(
    :irc_channel => irc_channel,
    :post_type   => tip,
    :person      => snusnu,
    :body        => "Be sure to checkout **#{bot}: show commands** to get an idea about what #{bot} can do for you",
    :tag_list    => "alfred"
  )

  note_1 = Post.create(
    :irc_channel => irc_channel,
    :post_type   => note,
    :person      => snusnu,
    :body        => "Have a look at #{bot}'s [sourcecode](http://github.com/snusnu/alfred)",
    :tag_list    => "alfred"
  )

end
