module Alfred

  module Helpers

    def post_header(post, person) # FIXME remove workaround for dm bug
      nick   = "<a href='/posts?person=#{person.name}'>#{person.name}</a>"
      header = "#{nick} posted the following <a href='/posts/#{post.id}'>#{post.post_type.name}</a>"
      if (count = post.follow_ups.size) > 0
        header << " (#{count} #{count == 1 ? 'reply' : 'replies'})"
      elsif post.reply?
        header << " to #{referrer_links(post)}"
      end
      header
    end

    def tag_links(tags, cloud = false)
      tags = tags.map { |t| [t, t.post_tags.size] }
      counts = tags.map { |t| t[1] }
      min, max = counts.min, counts.max
      tags.map do |t|
        name, count = t[0].name, t[1]
        tag_class = cloud ? "class='#{tag_class(min, max, count)}'" : ''
        "<a href='/posts?tags=#{name}' #{tag_class}>#{name}(#{count})</a>"
      end.join(' ')
    end

    def tag_class(min, max, count)
      distribution = (d = ((max - min) / 7) == 0) ? 1 : d
      if count == min
        'xx-small'
      elsif count == max
        'xx-large'
      elsif count > (min + distribution * 6)
        'x-large'
      elsif count > (min + distribution * 5)
        'large'
      elsif count > (min + distribution * 4)
        'medium'
      elsif count > (min + distribution * 3)
        'small'
      elsif count > (min + distribution * 2)
        'x-small'
      elsif count > (min + distribution)
        'xx-small'
      end
    end

    def referrer_links(answer)
      answer.referrers.map do |question|
        "<a href='/posts/#{question.id}'>##{question.id}</a>"
      end.join(', ')
    end

    def person_link(person)
      "<a href='/posts?person=#{person.name}' title='#{person.name}`s posts'>#{person.name}</a>"
    end

    def vote_text(post)
      sign = post.vote_sum > 0 ? '+' : ''
      <<-HTML
        <span class='votes'>
          <sup title='vote-sum' class='vote-sum'>#{sign}#{post.vote_sum}</sup>
          /
          <sub title='vote-count' class='vote-count'>#{post.vote_count}</sub>
        </span>
      HTML
    end

    def post_date(post)
      noday,month,day,year,time = post.created_at.strftime("%a %b %d %Y %H:%M").split(' ')
      <<-HTML
        <span class='post-date'>
         <span class="post-day">#{day}</span>
         <span class="post-month">#{month}</span>
         <span class="post-time">#{time}</span>
         <span class="post-year">#{year}</span>
        </span>
      HTML
    end

    def person_stats(person)
      <<-HTML
        <span class="person-stats">
          #{gravatar_image(person)}
          <sup title='person activity' class='person-activity'>23</sup>
          /
          <sub title='person accuracy' class='person-accuracy'>426</sub>
        </span>
      HTML
    end

    def gravatar_image(person)
      "<img class='gravatar' src='http://www.gravatar.com/avatar/#{person.gravatar_hash}?s=40&d=monsterid' alt='gravatar' />"
    end


    def post_body(post)
      RDiscount.new(post.body).to_html
    end

    def twitter_message(post)
      url = "#{Config.service_url}/posts/#{post.id}"
      # FIXME weird dm bug
      person = Person.get(post.person_id)
      case post.post_type.name
      when 'tip'
        "#{person.name} posted a tip at #{url}"
      when 'question'
        "#{person.name} asked a question at #{url}"
      when 'reply'
        "#{person.name} posted a reply at #{url}"
      when 'note'
        "#{person.name} posted a note at #{url}"
      else
        nil # prevents tweeting
      end
    end

    def tweet(post)
      if message = twitter_message(post)
        Thread.new { Alfred::Twitter.tweet(Config.twitter_bot_credentials, message) }
      end
    end

  end

end
