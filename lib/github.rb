require 'pp'

require 'json'
require 'restclient'
require 'nokogiri'

module Github

  extend self

  def root
    "http://github.com"
  end

  def api
    "#{root}/api/v2/json"
  end

  def user_url(user)
    "#{api}/user/show/#{user}"
  end

  def followers_url(user)
    "#{api}/user/show/#{user}/followers"
  end

  def followings_url(user)
    "#{api}/user/show/#{user}/following"
  end

  def repositories_url(user)
    "#{api}/repos/show/#{user}"
  end

  def repository_url(user, repository)
    "#{api}/repos/show/#{user}/#{repository}"
  end

  def collaborators_url(user, repository)
    "#{api}/repos/show/#{user}/#{repository}/collaborators"
  end

  def network_url(user, repository)
    "#{api}/repos/show/#{user}/#{repository}/network"
  end

  def contributors_url(user, repository)
    "#{api}/repos/show/#{user}/#{repository}/contributors"
  end

  def watchers_url(user, repository, page_num)
    "#{root}/#{user}/#{repository}/watchers?page=#{page_num}"
  end

  def project_url(user, repository)
    "#{root}/#{user}/#{repository}"
  end

  def account_url?(url)
    url.index('/').nil?
  end

  def import(config)
    Importer.new(config).run
  end

  def fetch_user_details(config)
    Importer.new(config).fetch_user_details
  end

  class Importer

    attr_reader :config, :ecosystem

    def initialize(config)
      @config = config
    end

    def run

      puts '-'*80
      puts "ALFRED: Importing the #{config['name']} ecosystem"

      ecosystem = create_ecosystem(config['name'])
      
      config['accounts'].each do |account|
      
        create_ecosystem_member(ecosystem, account)
      
        project_followings = followings(account)
        project_followers  = followers(account)
      
        project_followings.each { |user| create_ecosystem_member(ecosystem, user) }
        project_followers .each { |user| create_ecosystem_member(ecosystem, user) }
      
        puts "ALFRED: - #{project_followings.size} followings"
        puts "ALFRED: - #{project_followers.size } followers"
        puts '-'*80

      end

      with_repositories do |repository, category_name, official|

        repo_owner    = repository['owner']
        repo_name     = repository['name']
        repo_watchers = repository['watchers']
        kind          = official ? 'official ' : ''

        puts "ALFRED: Importing #{kind}repository (#{category_name}): #{repo_owner}/#{repo_name}"

        project = create_project(ecosystem, repository, category_name)

        project_contributors  = contributors(repository)
        project_collaborators = collaborators(repo_owner, repo_name)

        if category_name == 'compatible'

          # skip watchers and forkers for projects that are not specifically targetting
          # the current ecosystem, but record contribution and collaboration involvements
          # from already known community members. Also, add the author of the compatible
          # project, of course (but don't count commits).

          integrate_user(ecosystem, repo_owner, project, 'contributor')

          project_contributors.each do |contributor|
            # TODO Github API will change to be a hash instead of an array
            name, commit_count = contributor[0], contributor[1]
            if user = User.first(:github_name => name)
              create_involvement(project, user, 'contributor', commit_count)
            end
          end

          project_collaborators.each do |collaborator|
            if user = User.first(:github_name => collaborator)
              create_involvement(project, user, 'collaborator')
            end
          end
          
        else

          project_watchers      = watchers(repo_owner, repo_name, repo_watchers)
          project_forkers       = forkers(repo_owner, repo_name)

          project_contributors.each do |contributor|
            # TODO Github API will change to be a hash instead of an array
            name, commit_count = contributor[0], contributor[1]
            integrate_user(ecosystem, name, project, 'contributor', commit_count)
          end

          project_collaborators.each { |name| integrate_user(ecosystem, name, project, 'collaborator') }
          project_forkers      .each { |name| integrate_user(ecosystem, name, project, 'forker'      ) }
          project_watchers     .each { |name| integrate_user(ecosystem, name, project, 'watcher'     ) }

          puts "ALFRED: - #{project_collaborators.size} collaborators"
          puts "ALFRED: - #{project_contributors.size} contributors"
          puts "ALFRED: - #{project_forkers.size} forkers"
          puts "ALFRED: - #{project_watchers.size} watchers"
          puts '-'*80

        end

      end
    end

    def with_repositories
      config['members'].each do |member|
        name, category = member['name'], member['category']
        repos = if Github.account_url?(name)
          Tag.first_or_create(:name => 'official')
          official, repos = true, fetch_json(Github.repositories_url(name))['repositories'] 
          repos.each { |repo| yield(repo, 'official', official) }
        else
          official, repo = false, fetch_json(Github.repository_url(*member_info(name)))['repository']
          yield(repo, category, official)
        end
      end
    end

    def contributors(repository)
      fetch_json(Github.contributors_url(repository['owner'], repository['name']))['contributors']
    end

    def followers(user)
      fetch_json(Github.followers_url(user))['users']
    end

    def followings(user)
      fetch_json(Github.followings_url(user))['users']
    end

    def collaborators(user, repository)
      fetch_json(Github.collaborators_url(user, repository))['collaborators']
    end

    def forkers(user, repository)
      network_members = fetch_json(Github.network_url(user, repository))['network']
      network_members.inject([]) do |forkers, member|
        forkers << member['owner'] if member['fork']
        forkers
      end
    end

    def watchers(user, repository, nr_of_watchers)
      nr_of_pages    = (nr_of_watchers / 20.0).ceil
      (1..nr_of_pages).inject([]) do |watchers, page_num|
        watchers + parse_watchers(Github.watchers_url(user, repository, page_num))
      end
    end

    def fetch_user_details
      User.all.each do |user|
        begin
          details = fetch(Github.user_url(user.github_name), 1)
          user.update(:email => details['user']['email'])
        rescue RestClient::ResourceNotFound
          puts "FOUND ORPHAN: #{user.github_name} - deleting user"
          user.destroy
        rescue Exception => e
          puts e.backtrace
        end
      end
    end

  private

    def create_ecosystem(name)
      Ecosystem.create(:name => name)
    end

    def create_project(ecosystem, repository, category_name)
      project = Project.first_or_create(
        :github_url => Github.project_url(repository['owner'], repository['name'])
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

    def integrate_user(ecosystem, github_name, project, kind, commit_count = 0)
      user = create_user(github_name)
      create_ecosystem_member(ecosystem, user)
      create_involvement(project, user, kind, commit_count)
    end

    def create_user(github_name)
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

    def create_involvement(project, user, kind, commit_count = 0)
      Involvement.first_or_create(
        {:project => project, :user => user, :kind => kind},
        {:commit_count => commit_count}
      )
    end

    def create_ecosystem_member(ecosystem, user)
      user = user.is_a?(String) ? create_user(user) : user
      EcosystemMember.first_or_create(:ecosystem => ecosystem, :user => user)
    end

    def parse_watchers(url)
      fetch_html(url).css('#watchers li a:nth-child(2)').inject([]) do |watchers, a|
        watchers << a.content
      end
    end

    def member_info(member)
      member.split('/')
    end

    def fetch_html(url, wait = 1)
      Nokogiri::HTML(fetch(url, wait))
    end

    def fetch_json(url, wait = 1)
      JSON.parse(fetch(url, wait))
    end

    def fetch(url, wait)
      sleep(wait);
      puts "ALFRED: fetching #{url}"
      RestClient.get(url).body
    rescue Exception => e
      puts e.backtrace
    end
  end

end
