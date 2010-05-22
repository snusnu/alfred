module Alfred
  module Storage

    def self.create_ecosystem(name)
      Ecosystem.create(:name => name)
    end

    def self.create_project(ecosystem, repository, category_name, parent)
      project = Project.first_or_create(
        {:github_url => Github.project_url(repository['owner'], repository['name'])},
        {:parent => parent}
      )
      project.project_translations.create({ 
        :language    => Language['en_US'],
        :description => repository['description']
      })
      EcosystemProject.create(
        :ecosystem => ecosystem,
        :project => project
      )
      tag = Tag.first_or_create(:name => category_name)
      ProjectTag.first_or_create(:project => project, :tag => tag)
      ProjectCategory.first_or_create(:project => project, :tag => tag)
      project
    end

    def self.integrate_user(ecosystem, github_name, project, kind, commit_count = 0)
      user = create_user(github_name)
      create_ecosystem_member(ecosystem, user)
      create_involvement(project, user, kind, commit_count)
      user
    end

    def self.create_user(github_name)
      user = User.first_or_new(:github_name => github_name)
      return user if user.saved?

      details       = fetch_json(Github.user_url(github_name), 1)

      user.email    = details['user']['email']
      user.name     = details['user']['name']
      user.company  = details['user']['company']
      user.location = details['user']['location']
      user.blog     = details['user']['blog']

      user.save
      puts "ALFRED: --> created user #{github_name}"
      user
    end

    def self.create_involvement(project, user, kind, commit_count = 0)
      Involvement.first_or_create(
        {:project => project, :user => user, :kind => kind},
        {:commit_count => commit_count}
      )
    end

    def self.create_ecosystem_member(ecosystem, user)
      user = user.is_a?(String) ? create_user(user) : user
      EcosystemMember.first_or_create(:ecosystem => ecosystem, :user => user)
    end

  end # module Storage
end # module Alfred
