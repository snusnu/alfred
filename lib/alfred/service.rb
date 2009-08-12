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


    post '/posts' do
      post = create_post(params[:from], params[:body], params[:tags])
      message = "#{params[:from]} just posted a snippet to #{Config.service_url}/posts/#{post.id}"
      tweet_action(message)
      post.id.to_s
    end

    post '/questions' do
      post = create_post(params[:from], params[:body], params[:tags], true)
      message = "#{params[:from]} just asked a question at #{Config.service_url}/questions/#{post.id}"
      tweet_action(message)
      post.id.to_s
    end

    post '/answers' do
      if ids = params[:questions]
        ids = ids.gsub(',', ' ').strip.split(' ').uniq
        halt 404, 'No question to answer was specified' if ids.empty?
        post = create_post(params[:from], params[:body])
        question_ids = []
        ids.each do |question_id|
          if question = Post.get(question_id)
            QuestionAnswer.create(:source_id => question_id, :target => post)
            message = "#{params[:from]} just answered a question at #{Config.service_url}/answers/#{question_id}"
            tweet_action(message)
            question_ids << question_id
          end
        end
        question_ids.join(',')
      else
        halt 404, "You didn't specify any questions to answer"
      end
    end

    post '/posts/:post_id/vote/:impact' do
      post = Post.get(params[:post_id])
      halt 404, 'No post to vote was specified' unless post
      post.vote(params[:impact])
      "#{post.vote_sum},#{post.vote_count}"
    end

    get '/posts' do
      conditions = params[:question] == 'true' ? { :question => true } : {}
      order = { :order => [ :created_at.desc ] }
      if params[:tags]
        tag_names = Utils.tag_list(params[:tags])
        posts = []
        Tag.all(conditions.merge!(:name => tag_names)).each { |tag| posts += tag.posts.all(order) }
      else
        posts = Post.all(conditions.merge!(order))
      end
      erb :posts, :locals => { :posts => posts }
    end

    get '/posts/:id' do
      if post = Post.get(params[:id])
        erb :post, :locals => { :post => post }
      else
        halt 404, "No post stored with id #{params[:id]}"
      end
    end

    get '/questions' do
      redirect "/posts?question=true"
    end

    get '/questions/:id' do
      redirect "/posts/#{params[:id]}"
    end

    get '/answers' do
      posts = []
      QuestionAnswer.all.each do |question_answer|
        posts << question_answer.target
      end
      erb :posts, :locals => { :posts => posts }
    end

    get '/answers/:id' do
      redirect "/posts/#{params[:id]}"
    end

    get '/people/:person_name/posts' do
      conditions = params[:question] == 'true' ? { :question => true } : {}
      order = { :order => [ :created_at.desc ] }
      person = Person.first(:name => params[:person_name])
      halt 404, "No person with id = #{params[:person_name].inspect}" unless person
      if params[:tags]
        tag_names = Utils.tag_list(params[:tags])
        posts = []
        Tag.all(conditions.merge!(:name => tag_names)).each { |tag| posts += tag.posts.all(order.merge!(:person => person)) }
      else
        posts = person.posts.all(conditions.merge!(order))
      end
      erb :posts, :locals => { :posts => posts }
    end

    get '/people' do
      people = Person.all(:order => [ :name.asc ])
      erb :people, :locals => { :people => people }
    end

    get '/commands' do
      erb :commands
    end

    get '/tags' do
      erb :tags
    end

    # ---------------------------------------------------------------

    helpers do

      def post_tag_links(tags)
        tags.map { |t| "<a href='#{Config.service_url}/posts?tags=#{t.name}'>#{t.name}</a>" }.join(', ')
      end

      def tweet_action(message)
        Thread.new do
          # we don't need the response from twitter in this case so threading it seems feasible
          Alfred::Twitter.tweet(Config.twitter_bot_credentials, message)
        end
      end

      def create_post(from, body, tags = '', question = false)
        person = Person.first_or_create(:name => from)
        post   = Post.create(:person => person, :body => body, :question => question, :tag_list => tags)
        post
      end

      def questions_link_list(answer)
        answer.questions.map do |question|
          "<a href='#{Config.service_url}/questions/#{question.id}'>##{question.id}</a>"
        end.join(', ')
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

      def post_body(post)
        RDiscount.new(post.body).to_html
      end

      def person_link(person)
        "<a href='/people/#{person.name}/posts' title='#{person.name}`s posts'>#{person.name}</a>"
      end

    end

  end

end
