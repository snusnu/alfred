require 'rubygems'
require 'pathname'
require 'sinatra/base'

require 'dm-core'
require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-self_referential'

require 'models'
require 'twitter'

module Alfred

  SERVICE_ROOT = Pathname.new(__FILE__).dirname.expand_path.freeze

  class Service < Sinatra::Base

    enable :logging, :static, :dump_errors

    set :root, File.dirname(__FILE__)


    post '/posts' do
      person = Person.first_or_create(:name => params[:from])
      post   = Post.create(:person => person, :body => params[:body], :tag_list => params[:tags])

      Thread.new do
        name    = person.tweets? ? "@#{person.twitter_name}" : person.name
        message = "#{name} just posted to #{Config.service_url}/posts/#{post.id}"
        Alfred::Twitter.tweet(Config.twitter_bot_credentials, message)
      end

      post.id.to_s
    end

    get '/posts' do
      if params[:tags]
        tag = Tag.first(:name => params[:tags])
      end
      posts = tag ? tag.posts : Post.all
      erb :posts, :locals => { :posts => posts }
    end

    get '/commands' do
      erb :commands
    end

    get '/posts/:id' do
      if post = Post.get(params[:id])
        post.body
      else
        "sorry, no post stored with id #params{id}"
      end
    end

    get '/tags' do
      erb :tags
    end

    # ---------------------------------------------------------------

    helpers do

      def post_tag_links(tags)
        tags.map { |t| "<a href='#{Config.service_url}/posts?tags=#{t.name}'>#{t.name}</a>" }.join(', ')
      end

    end

  end

end
