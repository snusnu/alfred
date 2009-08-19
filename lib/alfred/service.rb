require 'rubygems'
require 'pathname'
require 'sinatra/base'
require 'rdiscount'

require 'utils'
require 'models'
require 'twitter'

require 'helpers'
require 'partials'

module Alfred

  class Service < Sinatra::Base

    enable :logging, :static, :dump_errors

    set :root, File.dirname(__FILE__)

    # ---------------------------- POST ROUTES -------------------------------------

    post '/people' do
      person = Person.first_or_create(:name => params[:name])
      person.id.to_s
    end

    post '/posts' do
      post = create_post(params[:type], params[:person], params[:body], params[:tags], params[:referrers])
      post.id.to_s
    end

    post '/votes' do
      post = Post.get(params[:post_id])
      halt 404, 'No post to vote was specified' unless post
      post.vote(params[:person], params[:impact])
      "#{post.vote_sum},#{post.vote_count}"
    end

    put '/people/:person' do
      person = Person.first(:name => params[:person])
      halt 404, "No person with name #{params[:person]}" unless person
      person.twitter_login = params[:twitter_login] if params[:twitter_login]
      person.twitter_login = params[:github_name  ] if params[:github_name  ]
      person.email_address = params[:email_address] if params[:email_address]
      person.gravatar      = params[:gravatar     ] if params[:gravatar     ]
      person.save
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


    get '/commands' do
      erb :commands
    end


    # ----------------------------- HELPERS ----------------------------------


    helpers do

      include Sinatra::Partials
      include Alfred::Helpers

      def create_post(type, person, body, tags, referrers)
        type = PostType.first(:name => type)
        halt 404, "No post type called #{type} exists" unless type
        person = Person.first_or_create(:name => person)
        post = Post.create(:post_type => type, :person => person, :body => body, :tag_list => tags)
        tweet(post)
        if referrers
          # silently filter duplicates and ignore invalid ids
          Post.all(:id => referrers.split(',').uniq.compact).each do |referrer|
            FollowUpPost.create(:source => referrer, :target => post)
          end
        end
        post
      end

      def show_posts(type, person, tags)
        conditions = { :order => [ :created_at.desc ] }
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
        halt 404, "No post with id = #{post_id} exists" unless post
        erb :post, :locals => { :post => post }
      end

    end

  end

end
