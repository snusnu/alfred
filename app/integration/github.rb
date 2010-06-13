require 'json'
require 'restclient'
require 'nokogiri'

module Github
  module API

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

    def watchers(user, repo, nr_of_watchers)
      nr_of_pages = (nr_of_watchers / 20.0).ceil
      (1..nr_of_pages).inject([]) do |result, page_num|
        watchers_page = fetch_html(watchers_url(user, repo, page_num))
        result + watchers_page.css(watchers_content_selector).inject([]) do |watchers, a|
          watchers << a.content
        end
      end
    end

    def watchers_url(user, repo, page_num)
      "#{root}/#{user}/#{repo}/watchers?page=#{page_num}"
    end

    def watchers_content_selector
      '#watchers li a:nth-child(2)'
    end

  end # module API

  extend API

end # module Github
