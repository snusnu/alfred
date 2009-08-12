require 'rubygems'
require 'pathname'
require 'sinatra/base'
require 'rdiscount'

require 'dm-core'
require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-self_referential'

require 'utils'
require 'models'
require 'twitter'

module Alfred

  SERVICE_ROOT = Pathname.new(__FILE__).dirname.expand_path.freeze

  class Service < Sinatra::Base

    enable :logging, :static, :dump_errors

    set :root, File.dirname(__FILE__)

    # ---------------------------- GET ROUTES -------------------------------------

    post '/posts' do
      post = create_post(params[:type], params[:person], params[:body], params[:tags], params[:referrers])
      tweet(post)
      post.id.to_s
    end

    post '/votes' do
      post = Post.get(params[:post_id])
      halt 404, 'No post to vote was specified' unless post
      post.vote(params[:person], params[:impact])
      "#{post.vote_sum},#{post.vote_count}"
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

      def create_post(type, person, body, tags, referrers)
        type = PostType.first(:name => type)
        halt 404, "No post type called #{type} exists" unless type
        person = Person.first_or_create(:name => person)
        post = Post.create(:post_type => type, :person => person, :body => body, :tag_list => tags)
        # silently filter duplicates and ignore invalid ids
        if referrers
          referrers.split(',').uniq.map { |id| Post.get(id) }.compact.each do |referrer|
            FollowUpPost.create(:source => post, :target => referrer)
            tweet(referrer)
          end
        end
        post
      end

      def show_posts(post_type, person, tags)
        conditions = { :order => [ :created_at.desc ] }
        conditions.merge!(:post_type => type)   if post_type = PostType.first(:name => post_type)
        conditions.merge!(:person    => person) if person = Person.first(:name => person)
        if tags
          tags = Alfred::Utils.tag_list(tags).map { |name| Tag.first(:name => name) }
          conditions.merge!(:tags => tags) unless tags.empty?
        end
        erb :posts, :locals => { :posts => Post.all(conditions) }
      end

      def show_post(post_id)
        post = Post.get(post_id)
        halt 404, "No post with id = #{post_id} exists" unless post
        erb :post, :locals => { :post => post }
      end

      def tag_links(tags)
        tags.map { |t| "<a href='/posts?tags=#{t.name}'>#{t.name}</a>" }.join(', ')
      end

      def referrer_links(answer)
        answer.questions.map do |question|
          "<a href='/posts/#{question.id}'>##{question.id}</a>"
        end.join(', ')
      end

      def person_link(person)
        "<a href='/posts?person=#{person.name}' title='#{person.name}`s posts'>#{person.name}</a>"
      end

      def vote_text(post)
        sign = post.vote_sum > 0 ? '+' : ''
        <<-HTML
          <span class='votes'>
            <span title='vote-sum' class='vote-sum'>#{sign}#{post.vote_sum}</span>
            /
            <span title='vote-count' class='vote-count'>#{post.vote_count}</span>
          </span>
        HTML
      end
      
      def post_date(post)
        noday,month,day,year,time = post.created_at.strftime("%a %b %d %Y %H:%M").split(' ')
        <<-HTML
          <span class='post-date'>
           <span class="post-day">#{day}</span> 
           <span class="post-month">#{month}</span> 
           <pre class="post-time">#{time}</pre>
           <span class="post-year">#{year}</span>
          </span>
        HTML
      end

      def post_body(post)
        RDiscount.new(post.body).to_html
      end

      def twitter_message(post)
        case post.post_type
        when 'post'
          "#{post.person.name} just posted a snippet to #{Config.service_url}/posts/#{post.id}"
        when 'questions'
          "#{post.person.name} just asked a question at #{Config.service_url}/posts/#{post.id}"
        when 'answer'
          "#{post.person.name} just answered a question at #{Config.service_url}/posts/#{question_id}"
        else
          nil
        end
      end

      def tweet(post)
        if message = twitter_message(post)
          Thread.new { Alfred::Twitter.tweet(Config.twitter_bot_credentials, message) }
        end
      end

    end

  end

end
