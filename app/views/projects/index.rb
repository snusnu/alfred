module Projects
  class Index < ::Layouts::Application

    def projects
      options = if params[:category]
        tag = Tag.first(:name => params[:category])
        { 'project_categories.tag_id' => tag.id }
      else
        {}
      end
      options.merge!(:order => [:github_url.asc], :parent => nil, :per_page => 20)
      Project.page(current_page, options).each do |project|
        {
          :name           => project.name,
          :description    => project.description(:en_US),
          :project_dom_id => project_dom_id(project),
          :github_url     => project.github_url,
          :fork_count     => fork_count(project)
        }
      end
    end

    def project_dom_id(project)
      "project-#{project.id}"
    end

  end
end
