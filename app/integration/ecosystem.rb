require 'pp'

require 'app/integration/github'

module Alfred

  def self.integrate(config)
    Integrator.integrate(config)
  end

  def self.prune(config)
    Importer.prune(config)
  end

  class Importer

    include Github::API

    attr_reader :config, :ecosystem, :imported

    def self.integrate(config)

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
        import_repository(ecosystem, repository, category_name, official)
      end

    end

    def with_repositories
      config['members'].each do |member|
        name, category = member['name'], member['category']
        repos = if account_url?(name)
          Tag.first_or_create(:name => 'official')
          official, repos = true, fetch_json(Github.repositories_url(name))['repositories'] 
          repos.each { |repo| yield(repo, 'official', official) }
        else
          official, repo = false, fetch_json(Github.repository_url(*member_info(name)))['repository']
          yield(repo, category, official)
        end
      end
    end

    def fetch_user_details
      User.all.each do |user|
        begin
          details = fetch(user_url(user.github_name), 1)
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

    def initialize(config)
      @config, @imported = config, []
    end

    def account_url?(url)
      url.index('/').nil?
    end

    def member_info(member)
      member.split('/')
    end

  end
end
