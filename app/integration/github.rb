require 'json'
require 'restclient'
require 'nokogiri'

module Github
  module API

    module Endpoints

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

      def repository_url(user, repo)
        "#{api}/repos/show/#{user}/#{repo}"
      end

      def collaborators_url(user, repo)
        "#{api}/repos/show/#{user}/#{repo}/collaborators"
      end

      def network_url(user, repo)
        "#{api}/repos/show/#{user}/#{repo}/network"
      end

      def contributors_url(user, repo)
        "#{api}/repos/show/#{user}/#{repo}/contributors"
      end

      def watchers_url(user, repo, page_num)
        "#{root}/#{user}/#{repo}/watchers?page=#{page_num}"
      end

      def project_url(user, repo)
        "#{root}/#{user}/#{repo}"
      end

      def watchers_content_selector
        '#watchers li a:nth-child(2)'
      end

    end # module Endpoints

    include Endpoints

    module Transport

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

    end # module Transport

    include Transport

    def contributors(repo)
      fetch_json(contributors_url(repo['owner'], repo['name']))['contributors']
    end

    def followers(user)
      fetch_json(followers_url(user))['users']
    end

    def followings(user)
      fetch_json(followings_url(user))['users']
    end

    def collaborators(user, repo)
      fetch_json(collaborators_url(user, repo))['collaborators']
    end

    def network(user, repo)
      fetch_json(network_url(user, repo))['network']
    end

    def watchers(user, repo, nr_of_watchers)
      nr_of_pages = (nr_of_watchers / 20.0).ceil
      (1..nr_of_pages).inject([]) do |result, page_num|
        watchers_page = fetch_html(watchers_url(user, repo, page_num))
        result + watchers_page.css(watchers_content_selector).inject([]) do |watchers, a|
          watchers << a.content
        end
      end
    end

  end # module API

  extend API

end # module Github
