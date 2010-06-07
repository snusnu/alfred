module Ecosystems
  class Stats < ::Layouts::Application

    def stats
      Ecosystem.stats(params[:id], current_page).map do |info|
        user = User.first(:github_name => info.first)
        github_name  = user.github_name
        twitter_name = user.twitter_name
        {
          :github_name  => github_name,
          :github_link  => github_link(github_name),
          :twitter_name => twitter_name,
          :twitter_link => twitter_link(twitter_name),
          :gravatar     => gravatar_image(user),
          :commits      => info.last
        }
      end
    end

    def pagination_links
      @pagination_links ||= begin
        pager = DataMapper::Pager.new(:page => current_page.to_i, :limit => 60, :total => Ecosystem.committers.count)
        pager.to_html("/ecosystems/#{Alfred.config['ecosystem']['name']}/stats", :size => 3)
      end
    end

  private

    def github_link(name)
      "<a href='http://github.com/#{name}' title='#{name}\'s Github page'>#{name}</a>"
    end

    def twitter_link(name)
      "<a href='http://twitter.com/#{name}' title='#{name}\'s Twitter page'>#{name}</a>"
    end

  end
end
