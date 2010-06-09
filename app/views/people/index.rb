module People
  class Index < ::Layouts::Application

    def pagination_links
      @pagination_links ||= pager_for(Person).to_html('/people', :size => 3)
    end

    def people
      Person.page(current_page, :order => [ :github_name.asc ], :per_page => 72).map do |user|
        github_name  = user.github_name
        twitter_name = user.twitter_name
        {
          :github_name         => github_name,
          :github_link         => github_link(github_name),
          :twitter_name        => twitter_name,
          :twitter_link        => twitter_link(twitter_name),
          :gravatar            => gravatar_image(user),
          :has_personal_posts? => user.has_personal_posts?,
          :personal_posts      => personal_posts(github_name)
        }
      end
    end

  private

    # TODO extract into common module (see views/ecosystems/stats)

    def personal_posts(name)
      "<a href='/posts?person=#{name}&personal=true'>Posts</a>"
    end

    def github_link(name)
      "<a href='http://github.com/#{name}' title='#{name}\'s Github page'>#{name}</a>"
    end

    def twitter_link(name)
      "<a href='http://twitter.com/#{name}' title='#{name}\'s Twitter page'>#{name}</a>"
    end

  end
end
