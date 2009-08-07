require 'rubygems'
require 'sinatra/base'

require 'models'

module Alfred

  class Service < Sinatra::Base

    enable :logging

    post '/posts' do

      puts "Received post from #{params[:from]}"

      person = Person.first_or_create(:name => params[:from])
      post   = Post.create(:person => person, :body => params[:body], :tag_list => params[:tags])

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

  Service.run! :host => Config['service']['host'], :port => Config['service']['port']

end
