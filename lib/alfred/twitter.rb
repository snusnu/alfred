require 'restclient'
require 'json'

module Alfred
  module Twitter

    def self.tweet(credentials, message)
      JSON.parse(RestClient.post(status_update_url(credentials), :status => message))
    end

    def self.follow(credentials, user)
      "http://#{credentials}@twitter.com/friendships/create/#{user}"
    end


    def self.status_update_url(credentials)
      "http://#{credentials}@twitter.com/statuses/update.json"
    end

    def self.status_url(user, tweet_id)
      "http://twitter.com/#{user}/status/#{tweet_id}"
    end

  end
end
