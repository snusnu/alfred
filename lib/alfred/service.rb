require 'rubygems'
require 'pathname'
require 'sinatra/base'

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
      post.id.to_s
    end

    post '/questions' do
      post = create_post(params[:from], params[:body], params[:tags], true)
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
            question_ids << question_id
          end
        end
        question_ids.join(',')
      else

      end
    end

    get '/posts' do
      conditions = params[:question] == 'true' ? { :question => true } : {}
      if params[:tags]
        tag_names = Utils.tag_list(params[:tags])
        posts = []
        Tag.all(conditions.merge!(:name => tag_names)).each { |tag| posts += tag.posts }
      else
        posts = Post.all(conditions)
      end
      erb :posts, :locals => { :posts => posts }
    end

    get '/posts/:id' do
      if post = Post.get(params[:id])
        erb :post, :locals => { :post => post }
      else
        halt 404, "No post stored with id #params{id}"
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

      def tweet_action(person, post)
        Thread.new do
          name    = person.tweets? ? "@#{person.twitter_name}" : person.name
          message = "#{name} just posted #{Config.service_url}/posts/#{post.id}"
          Alfred::Twitter.tweet(Config.twitter_bot_credentials, message)
        end
      end

      def create_post(from, body, tags = '', question = false)
        person = Person.first_or_create(:name => from)
        post   = Post.create(:person => person, :body => body, :question => question, :tag_list => tags)
        #tweet_action(person, post)
        post
      end

      def questions_link_list(answer)
        answer.questions.map do |question|
          "<a href='#{Config.service_url}/questions/#{question.id}'>##{question.id}</a>"
        end.join(', ')
      end
    end

  end

end
