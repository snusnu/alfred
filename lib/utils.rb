require 'tzinfo'

module Alfred

  module Utils

    def self.tag_list(tags)
      tags && tags.size > 0 ? tags.gsub(',', ' ').strip.split(' ').uniq : []
    end

    IRCLOGGER_URL = 'http://irclogger.com'

    def self.logged_channel?(channel)
      JSON.parse(RestClient.get("#{IRCLOGGER_URL}/channels.json")).any? do |entry|
        entry['channel'] == channel
      end
    end

    def self.fetch_remote_conversation(post, start, stop, people = [])
      names = people.map { |p| p.name }
      response = JSON.parse(RestClient.get(Alfred::Utils.remote_conversation_url(post, start, stop)))
      if names.empty?
        # filter out join/part messages but use all others
        response.select { |message| message['nick'] != "" }
      else
        response.select { |message| names.include?(message['nick']) }
      end
    end

    def self.remote_conversation_url(post, start, stop)
      base_url = "#{IRCLOGGER_URL}/#{post.irc_channel.raw_channel_name}"
      "#{base_url}/slice/#{start.to_time.to_i}/#{stop.to_time.to_i}"
    end

    def self.remote_permalink(irc_channel, timestamp)
      # TODO hopefully irclogger will get UTC date urls
      day = TZInfo::Timezone.get('America/Denver').utc_to_local(Time.at(timestamp)).strftime('%Y-%m-%d')
      channel = irc_channel.raw_channel_name
      "http://irclogger.com/#{channel}/#{day}#msg_#{timestamp}"
    end

  end

end
