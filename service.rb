require 'rubygems'
require 'pathname'
require 'sinatra/base'
require 'rdiscount'
require 'json'

require 'lib/utils'
require 'lib/twitter'
require 'lib/helpers'
require 'lib/partials'

require 'models'

module Alfred

  class Service < Sinatra::Base

    enable :logging, :static, :dump_errors

    set :root, File.dirname(__FILE__)

    # ---------------------------- POST ROUTES -------------------------------------

    post '/people' do
      Person.first_or_create(:name => params[:name]).to_json
    end

    post '/posts' do
      post = create_post(
        params[:channel],
        params[:type],
        params[:person],
        params[:body],
        params[:tags],
        params[:via],
        params[:start],
        params[:stop],
        params[:people],
        params[:referrers]
      )
      halt 500, "Failed to create post" unless post
      post.to_json
    end

    post '/votes' do
      post = Post.get(params[:post_id])
      halt 404, 'No post to vote was specified' unless post
      post.vote(params[:person], params[:impact])
      post.to_json
    end

    put '/people/:person' do
      person = Person.first(:name => params[:person])
      halt 404, "No person with name #{params[:person]}" unless person
      person.twitter_name  = params[:twitter_name ] if params[:twitter_name ]
      person.github_name   = params[:github_name  ] if params[:github_name  ]
      person.email_address = params[:email_address] if params[:email_address]
      person.save
      person.to_json
    end

    # ---------------------------- GET ROUTES -------------------------------------


    get '/' do
      redirect '/posts'
    end


    get '/posts' do
      show_posts(params[:type], params[:person], params[:tags])
    end

    get '/posts/:id' do
      show_post(params[:id])
    end


    get '/people' do
      erb :people, :locals => { :people => Person.all(:order => [ :name.asc ]) }
    end

    get '/tags' do
      erb :tags, :locals => { :tags => Tag.all }
    end

    get '/tags.json' do
      Tag.all.map do |t|
        { 'name'  => t.name,
          'count' => t.post_tags.size,
          'link'  => "#{Config.service_url}/posts?tags=#{t.name}"
        }
      end.to_json
    end

    get '/commands' do
      erb :commands
    end


    # ----------------------------- HELPERS ----------------------------------


    helpers do

      include Sinatra::Partials
      include Alfred::Helpers

      def create_post(channel, type, person, body, tags, via, start, stop, people, referrers)

        unless post_type = PostType.first(:name => type)
          halt 404, "No post type called #{type} exists"
        end

        if (conversation = (post_type.name == 'conversation')) && !(start && stop)
          halt 500, "No start and stop dates given for conversation"
        end

        channel = IrcChannel.channel(:server => Config['irc']['server'], :channel => channel)
        person  = Person.first_or_create(:name => person)
        via     = Person.first_or_create(:name => via   ) if via

        post = Post.create(
          :irc_channel => channel,
          :post_type => post_type,
          :person => person,
          :via => via,
          :body => body,
          :tag_list => tags
        )

        if conversation
          names  = people.gsub(',',' ').strip.split(' ')
          people = names.map { |name| Person.first_or_create(:name => name) }
          post.conversation = Conversation.new(:start => start, :stop => stop, :people => people)
          post.save
        end

        tweet(post)

        if referrers
          referring_posts = []
          # silently filter duplicates and ignore invalid ids
          Post.all(:id => referrers.split(',').uniq.compact).each do |referrer|
            referring_posts << referrer
            FollowUpPost.create(:source => referrer, :target => post)
          end
          # tag the reply with all tags used in the referrers
          referring_tags = referring_posts.map do |p|
            Post.get(p.id).tag_list # FIXME weird dm bug workaround
          end.join(',').split(',').compact.uniq
          post.tag_list = referring_tags.join(',')
          post.save
        end
        post
      end

      def show_posts(type, person, tags)
        conditions = { :order => [ :created_at.desc ] }

        # FIXME weird dm bug workaround
        conditions.merge!(:post_type_id => type.id)   if type   = PostType.first(:name => type)
        conditions.merge!(:person_id    => person.id) if person = Person.first(:name => person)
        if tags
          tags = Alfred::Utils.tag_list(tags).map { |name| Tag.first(:name => name).id }
          conditions.merge!('post_tags.tag_id' => tags) unless tags.empty?
        end

        erb :posts, :locals => { :posts => Post.all(conditions) }
      end

      def show_post(post_id)

        post = Post.get(post_id)

        # FIXME weird dm bug workaround
        person = Person.get(post.person_id)
        tags = Tag.all(:id => post.post_tags.map { |t| t.tag_id })

        halt 404, "No post with id = #{post_id} exists" unless post
        erb :post, :locals => { :post => post, :person => person, :tags => tags, :detail_view => true }
      end

    end

  end

  Service.run! :host => Config['service']['host'], :port => Config['service']['port']

end
