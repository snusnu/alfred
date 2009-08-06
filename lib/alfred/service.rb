require 'models'

module Alfred

  class Service < Sinatra::Base

    enable :logging

    post '/posts' do

      puts "Received post from #{params[:from]}"
      
      person = Person.first_or_create(:name => params[:from])
      post   = Post.create(:person => person, :body => params[:body], :tags_list => params[:tags])
      
      post.id.to_s
    end
    
    get '/posts' do
      html = "<dl>"
      Post.all.each do |p|
        html << "<dt>#{p.tags_list}</dt>"
        html << "<dd>#{p.body}</dd>"
      end
      html << '</dl>'
      html
    end

    get '/commands' do
      %w{
        <dl>
          <dt>prints a link to alfred's main site</dt>
          <dd>show site</dd>
          <dt>prints a list of available tags and their entry counts</dt>
          <dd>show tags</dd>
        </dl>
      }
    end

    get '/posts/:id' do
      if post = Post.get(params[:id])
        post.body
      else
        "sorry, no post stored with id #params{id}"
      end
    end

    get '/tags' do
      Tag.all.map { |t| t.name }.join(', ')
    end

  end

end