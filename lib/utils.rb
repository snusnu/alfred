module Alfred

  module Utils

    def self.tag_list(tags)
      tags && tags.size > 0 ? tags.gsub(',', ' ').strip.split(' ').uniq : []
    end

    IRCLOGGER_CHANNELS_URL = 'http://irclogger.com/channels.json'

    def self.logged_channel?(channel)
      JSON.parse(RestClient.get(IRCLOGGER_CHANNELS_URL)).any? do |entry|
        entry['channel'] == channel
      end
    end

  end

end
