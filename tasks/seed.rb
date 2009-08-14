desc "Generate and seed the database"
task :seed do

  require 'rubygems'
  require 'pathname'

  $LOAD_PATH.unshift(Pathname.new(__FILE__).dirname.parent.expand_path.join('lib', 'alfred'))

  require 'models'

  DataMapper.auto_migrate!


  bot = Config['irc']['nick']  

  documentation = PostType.create :name => 'documentation'
  question      = PostType.create :name => 'question'
  reply         = PostType.create :name => 'reply'
  note          = PostType.create :name => 'note'

  snusnu = Person.create(
    :name => 'snusnu',
    :twitter_login => 'gmsmon',
    :github_name   => 'snusnu',
    :email_address => 'gamsnjaga@gmail.com',
    :gravatar => true
  )

  armitage = Person.create(
    :name => 'armitage',
    :twitter_login => 'lordarmitage',
    :github_name   => 'armitage',
    :email_address => 'lord.armitage@gmail.com',
    :gravatar => true
  )

  question_1 = Post.create(
    :post_type => question,
    :person    => snusnu,
    :body      => "Are we up and running?",
    :tag_list  => "alfred"
  )

  reply_1 = Post.create(
    :post_type => reply,
    :person    => snusnu,
    :body      => "Yeah, sure thing!",
    :tag_list  => "alfred"
  )

  reply_1.vote('armitage', '+')

  FollowUpPost.create(
    :source => question_1,
    :target => reply_1
  )

  question_2 = Post.create(
    :post_type => question,
    :person    => snusnu,
    :body      => "Do we have nice styles?",
    :tag_list  => "alfred"
  )

  reply_2 = Post.create(
    :post_type => reply,
    :person    => armitage,
    :body      => "Yeah, sure thing!",
    :tag_list  => "alfred"
  )

  reply_2.vote('snusnu', '+')

  FollowUpPost.create(
    :source => question_2,
    :target => reply_2
  )

  documentation_1 = Post.create(
    :post_type => documentation,
    :person    => snusnu,
    :body      => "Be sure to checkout **#{bot}: show commands** to get an idea about what #{bot} can do for you",
    :tag_list  => "alfred"
  )

  note_1 = Post.create(
    :post_type => note,
    :person    => snusnu,
    :body      => "Have a look at #{bot}'s [sourcecode](http://github.com/snusnu/alfred)",
    :tag_list  => "alfred"
  )

end