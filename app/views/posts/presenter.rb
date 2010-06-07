require 'rdiscount'

module Posts

  module Helpers
    def detail_view?
      @detail_view
    end

    def conversation
      post.conversation
    end

    def conversation?
      conversation && conversation.messages.count > 0
    end

    def conversation_irc_link
      irc_link(post.irc_channel)
    end

    def conversation_messages
      conversation.messages.map do |message|
        {
          :message_nick      => message.person.name,
          :message_timestamp => Time.at(message.timestamp).strftime("%H:%M"),
          :message_permalink => message.permalink,
          :message_body      => auto_link_urls(message.body)
        }
      end
    end

    def post_id
      post.id
    end

    def post_type_name
      post.post_type.name
    end

    def header
      post_header(post, person)
    end

    def date
      post_date(post)
    end

    def statistics
      person_stats(person)
    end

    def vote_info
      vote_text(post)
    end

    def permalink
      post.permalink
    end

    def tag_list
      tag_links(tags)
    end

    def body
      ::RDiscount.new(post.body).to_html
    end

    def person
      Person.get(post.person_id)
    end

    def tags
      Tag.all(:id => post.post_tags.map { |t| t.tag_id })
    end

    def show_follow_ups?
      detail_view? && post.has_follow_ups?
    end

    def follow_ups
      return [] unless show_follow_ups?
      post.follow_ups.all.map do |reply|
        new(reply, false)
      end      
    end
  end

  class Presenter

    include ApplicationHelper
    include Posts::Helpers

    attr_reader :view, :post

    def initialize(view, post, detail_view)
      @view, @post, @detail_view = view, post, detail_view
    end

  end
end
