# require 'rubygems'
# require 'pathname'
# require 'sinatra/base'
# require 'rdiscount'
# require 'json'
#
# require 'lib/utils'
# require 'lib/twitter'
# require 'lib/helpers'
# require 'lib/partials'
#
# require 'models'
#
# module Alfred
#
#   class Service < Sinatra::Base
#
#     enable :logging, :static, :dump_errors
#
#     set :root, File.dirname(__FILE__)
#
#     # ---------------------------- POST ROUTES -------------------------------------
#
#     post '/people' do
#       Person.first_or_create(:name => params[:name]).to_json
#     end
#
#     post '/posts' do
#       post = create_post(
#         params[:channel],
#         params[:type],
#         params[:person],
#         params[:body],
#         params[:tags],
#         params[:via],
#         params[:start],
#         params[:stop],
#         params[:people],
#         params[:referrers],
#         params[:personal]
#       )
#       halt 500, "Failed to create post" unless post
#       post.to_json
#     end
#
#     post '/votes' do
#       post = Post.get(params[:post_id])
#       halt 404, 'No post to vote was specified' unless post
#       post.vote(params[:person], params[:impact])
#       post.to_json
#     end
#
#     put '/people/:person' do
#       person = Person.first(:name => params[:person])
#       halt 404, "No person with name #{params[:person]}" unless person
#       person.real_name     = params[:real_name    ] if params[:real_name    ]
#       person.twitter_name  = params[:twitter_name ] if params[:twitter_name ]
#       person.github_name   = params[:github_name  ] if params[:github_name  ]
#       person.email_address = params[:email_address] if params[:email_address]
#       person.save
#       person.to_json
#     end
#
#     # ---------------------------- GET ROUTES -------------------------------------
#
#
#     get '/' do
#       redirect '/posts'
#     end
#
#     get '/projects' do
#       options = if params[:category]
#         tag = Tag.first(:name => params[:category])
#         { 'project_categories.tag_id' => tag.id }
#       else
#         {}
#       end
#       erb :'projects/index', :locals => { :options => options }
#     end
#
#     # DONE
#     get '/ecosystems/:name/stats' do
#       erb :'ecosystems/stats', :locals => { :ecosystem_name => params[:name] }
#     end
#
#     get '/posts' do
#       show_posts(params[:type], params[:person], params[:tags], params[:personal])
#     end
#
#     get '/posts/:id' do
#       show_post(params[:id])
#     end
#
#     # DONE
#     get '/people' do
#       erb :people
#     end
#
#     # DONE
#     get '/tags' do
#       erb :tags, :locals => { :tags => Tag.all }
#     end
#
#     # TODO implement with rails
#     get '/tags.json' do
#       Tag.all.map do |t|
#         { 'name'  => t.name,
#           'count' => t.post_tags.size,
#           'link'  => "#{Config.service_url}/posts?tags=#{t.name}"
#         }
#       end.to_json
#     end
#
#     # DONE
#     get '/commands' do
#       erb :commands
#     end
#
#     # ----------------------- POST RECEIVE HOOKS -----------------------------
#
#     post '/github/hook' do
#       payload = JSON.parse(params[:payload])
#       user_name      = payload['repository']['owner']['name']
#       project_name   = payload['repository']['name']
#       watchers_count = payload['repository']['watchers']
#     end
#
#     # ----------------------------- HELPERS ----------------------------------
#
#
#     helpers do
#
#       include Rack::Utils
#       alias_method :h, :escape_html
#
#       include Sinatra::Partials
#       include Alfred::Helpers
#
#       def create_post(channel, type, person, body, tags, via, start, stop, people, referrers, personal)
#
#         unless post_type = PostType.first(:name => type)
#           halt 404, "No post type called #{type} exists"
#         end
#
#         if (conversation = (post_type.name == 'conversation')) && !(start && stop)
#           halt 500, "No start and stop dates given for conversation"
#         end
#
#         channel = IrcChannel.channel(:server => Config['irc']['server'], :channel => channel)
#         person  = Person.first_or_create(:name => person)
#         via     = Person.first_or_create(:name => via   ) if via
#
#         post = Post.create(
#           :irc_channel => channel,
#           :post_type => post_type,
#           :person => person,
#           :via => via,
#           :body => body,
#           :tag_list => tags,
#           :personal => personal
#         )
#
#         if conversation
#           names  = people.gsub(',',' ').strip.split(' ')
#           people = names.map { |name| Person.first_or_create(:name => name) }
#           post.conversation = Conversation.new(:start => start, :stop => stop, :people => people)
#           post.save
#         end
#
#
#         if referrers
#           referring_posts = []
#           # silently filter duplicates and ignore invalid ids
#           Post.all(:id => referrers.split(',').uniq.compact).each do |referrer|
#             referring_posts << referrer
#             FollowUpPost.create(:source => referrer, :target => post)
#           end
#           # tag the reply with all tags used in the referrers
#           referring_tags = referring_posts.map do |p|
#             Post.get(p.id).tag_list # FIXME weird dm bug workaround
#           end.join(',').split(',').compact.uniq
#           post.tag_list = referring_tags.join(',')
#           post.save
#         end
#
#         # these run in separate threads
#
#         tweet(post)   unless post.personal
#         post.remember unless post.note? && post.personal
#
#         post
#       end
#
#       def show_posts(type, person, tags, personal = false)
#         conditions = { :order => [ :created_at.desc ], :personal => personal || false }
#
#         # FIXME weird dm bug workaround
#         conditions.merge!(:post_type_id => type.id)   if type   = PostType.first(:name => type)
#         conditions.merge!(:person_id    => person.id) if person = Person.first(:name => person)
#         if tags
#           tags = Alfred::Utils.tag_list(tags).map { |name| Tag.first(:name => name).id }
#           conditions.merge!('post_tags.tag_id' => tags) unless tags.empty?
#         end
#
#         erb :posts, :locals => { :posts => Post.all(conditions) }
#       end
#
#       def show_post(post_id)
#
#         post = Post.get(post_id)
#
#         # FIXME weird dm bug workaround
#         person = Person.get(post.person_id)
#         tags = Tag.all(:id => post.post_tags.map { |t| t.tag_id })
#
#         halt 404, "No post with id = #{post_id} exists" unless post
#         erb :post, :locals => { :post => post, :person => person, :tags => tags, :detail_view => true }
#       end
#
#     end
#
#   end
#
# end
