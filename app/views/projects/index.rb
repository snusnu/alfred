module Projects
  class Index < ::Layouts::Application

    def projects
      options = { :order => [ :github_url ], :parent => nil, :per_page => 20 }

      if params.key?(:category)
        tag = Tag.first(:name => params[:category])
        options.update('project_categories.tag_id' => tag.id)
      end

      Project.page(current_page, options).map do |project|
        {
          :name           => project.name,
          :description    => project.description(:en_US),
          :project_dom_id => project_dom_id(project),
          :github_url     => project.github_url,
          :fork_count     => fork_count(project),
        }
      end
    end

    def pagination_links
      url = "/projects"
      url += "?category=#{params[:category]}" if params[:category]
      @pagination_links ||= pager_for(Project).to_html(url, :size => 3)
    end

    def project_dom_id(project)
      "project-#{project.id}"
    end

  end
end
