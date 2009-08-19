module Alfred

  module Utils

    def self.tag_list(tags)
      tags && tags.size > 0 ? tags.gsub(',', ' ').strip.split(' ').uniq : []
    end

  end

end
