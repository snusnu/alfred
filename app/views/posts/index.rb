require File.expand_path('../presenter', __FILE__)

module Posts

  class Index < ::Layouts::Application

    def posts
      Post.page(current_page, conditions.merge(:per_page => 18)).map do |post|
        Presenter.new(self, post, false)
      end
    end

    def pagination_links
      @pagination_links ||= pager_for(Post).to_html('/posts', :size => 3)
    end

  private

    def conditions
      type, person, tags, personal = params[:type], params[:person], params[:tags], params[:personal]
      conditions = { :order => [ :created_at.desc ], :personal => personal || false }
      # FIXME weird dm bug workaround
      conditions.merge!(:post_type_id => type.id)   if type   = PostType.first(:name => type)
      conditions.merge!(:person_id    => person.id) if person = Person.first(:name => person)
      if tags
        tags = Alfred::Utils.tag_list(tags).map { |name| Tag.first(:name => name).id }
        conditions.merge!('post_tags.tag_id' => tags) unless tags.empty?
      end
      conditions
    end

  end
end
