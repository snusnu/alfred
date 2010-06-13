require 'app/integration/github'

module Alfred
  class Repository

    include Github::API

    attr_reader :owner, :repo

    def self.integrate(owner, repo)
      new(owner, repo).integrate
    end


    def integrate(ecosystem, repository, category_name, official, parent = nil)

      repo_owner    = repository['owner']
      repo_name     = repository['name']
      repo_watchers = repository['watchers']
      kind          = official ? 'official ' : ''

      puts "ALFRED: Importing #{kind}repository (#{category_name}): #{repo_owner}/#{repo_name}"

      project_network  = network(repo_owner, repo_name)

      puts "-"*80
      puts "ALFRED: owner - #{repo_owner}/#{repo_name}"
      puts "-"*80
      project_network.each do |fork|
        name    = "#{fork['owner']}/#{fork['name']}"
        current = (name == "#{repo_owner}/#{repo_name}")
        project_name = name.rjust(40)
        project_name << ' <-- CURRENT' if current
        puts "ALFRED: #{project_name}"
      end
      puts "-"*80

      forks    = project_network.select { |repo| repo['fork'] == true }
      original = (project_network - forks).first

      puts "ORIGINAL: #{original['owner']}/#{original['name']}"

      unless Project.first(:github_url => "http://github.com/#{original['owner']}/#{original['name']}")
        puts "--> RECURSIVE LOOKUP for ORIGINAL: #{original['owner']}/#{original['name']}"
        import_repository(ecosystem, original, category_name, official)
      end

      project_network.each do |repo|
        if repo['fork'] == true
          puts "URL: fork url = #{repo['url']}"
          unless Project.first(:github_url => repo['url'])
            fork   = fetch_json(Github.repository_url(repo['owner'], repo['name']))
            puts "FORK: #{fork.inspect}"
            parent = Project.first(:github_url => "http://github.com/#{fork['repository']['source']}")
            puts "FORK:   #{repo['owner']}/#{repo['name']}"
            puts "SOURCE: #{fork['repository']['source']}"
            puts "PARENT: #{fork['repository']['parent']}"
            if parent
              import_repository(ecosystem, repo, category_name, false, parent)
            else
              import_repository(ecosystem, fork['repository'], category_name, false)
            end
          end
        else

        end
      end

      project = create_project(ecosystem, repository, category_name, parent)

      if category_name == 'compatible'

        # skip watchers and forkers for projects that are not specifically targetting
        # the current ecosystem, but record contribution and collaboration involvements
        # from already known community members. Also, add the author of the compatible
        # project, of course (but don't count commits).


        if parent

          integrate_user(ecosystem, repo_owner, project, 'forker')

        else

          # don't create involvements for compatible forks
          # (needs repo clones to be done properly)

          contributors(repository).each do |contributor|
            # TODO Github API will change to be a hash instead of an array
            name, commit_count = contributor[0], contributor[1]
            if user = Person.first(:github_name => name)
              create_involvement(project, user, 'contributor', commit_count)
            end
          end

          collaborators(repo_owner, repo_name).each do |collaborator|
            if user = Person.first(:github_name => collaborator)
              create_involvement(project, user, 'collaborator')
            end
          end

        end

      else

        if parent

          # register the owner as a forker, but don't count
          # duplicate commits, collaborators and watchers
          integrate_user(ecosystem, repo_owner, project, 'forker')

        else

          # don't create involvements for forks
          # (needs repo clones to be done properly)

          contributors(repository).each do |contributor|
            # TODO Github API will change to be a hash instead of an array
            name, commit_count = contributor[0], contributor[1]
            integrate_user(ecosystem, name, project, 'contributor', commit_count)
          end

          collaborators(repo_owner, repo_name).each do |name|
            integrate_user(ecosystem, name, project, 'collaborator')
          end

          watchers(repo_owner, repo_name, repo_watchers).each do |name|
            integrate_user(ecosystem, name, project, 'watcher')
          end

        end

      end

      imported << project

    end


  private

    def initialize(ecosystem, owner, repo)
      @ecosystem, @owner, @repo = ecosystem, owner, repo
    end

    def network
      
    end

  end
end
