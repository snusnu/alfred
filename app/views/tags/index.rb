module Tags
  class Index < ::Layouts::Application

    def has_tags?
      Tag.count > 0
    end

    def tags
      tag_links(Tag.all, true)
    end

  end
end
