module Layouts
  class Application < Mustache::Rails

    def bot
      "<a href='http://github.com/snusnu/alfred'>#{Alfred.config['irc']['nick']}</a>"
    end

    def bot_name
      Alfred.config['irc']['nick']
    end

    def project_name
      Alfred.config['project']['name']
    end

    def ecosystem_name
      Alfred.config['ecosystem']['name']
    end

    def total_user_count
      User.count
    end

    def total_watcher_count
      Involvement.nr_of_watchers
    end

    def total_fork_count
      Project.count(:parent.not => nil)
    end

    def project_count_without_forks
      Project.count(:parent => nil)
    end

    def total_collaborator_count
      Involvement.nr_of_collaborators
    end

    def total_contributor_count
      Involvement.nr_of_contributors
    end


    def project_categories
      ProjectCategory.all(:fields => [:tag_id], :unique => true).map do |pc|
        { :url           => "/projects?category=#{pc.tag.name}",
          :category_name => pc.tag.name,
          :project_count => ProjectCategory.count(:tag => pc.tag, 'project.parent_id' => nil)
        }
      end
    end

    def channel_names
      Alfred.config['irc']['channels'].map { |c| "##{c}"}
    end

    def channels
      IrcChannel.all(:channel => channel_names)
    end

    def channel_word
      channel_names.size > 1 ? 'channels' : 'channel'
    end

  end
end
