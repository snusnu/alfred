require 'rubygems'
require 'pathname'
require 'rake'

ROOT = Pathname(__FILE__).dirname.expand_path

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "alfred #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Generate and seed the database"
task :seed do

  require 'rubygems'
  require 'pathname'

  $LOAD_PATH.unshift(File.dirname(__FILE__))

  require 'models'

  DataMapper.auto_migrate!


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
    :twitter_login => 'gmsmon',
    :github_name   => 'snusnu',
    :email_address => 'gamsnjaga@gmail.com'
  )

  armitage = Person.create(
    :name => 'armitage',
    :twitter_login => 'lordarmitage',
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
