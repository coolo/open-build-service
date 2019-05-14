module Webui2::ProjectController
  def webui2_index
    show_all = (params[:all].to_s == 'true')
    atype = AttribType.find_by_namespace_and_name!('OBS', 'VeryImportantProject')
    @important_projects = Project.find_by_attribute_type(atype).where('name <> ?', 'deleted').pluck(:name, :title)

    if @spider_bot
      render :list_simple
    else
      respond_to do |format|
        format.html { render :list }
        format.json { render json: ProjectDatatable.new(params, view_context: view_context, show_all: show_all) }
      end
    end
  end

  def webui2_show
    @remote_projects = Project.where.not(remoteurl: nil).pluck(:id, :name, :title)
  end

  def webui2_subprojects
    respond_to do |format|
      format.html
      format.json { render json: ProjectDatatable.new(params, view_context: view_context, projects: project_for_datatable) }
    end
  end

  def webui2_monitor
    unless (buildresult = monitor_buildresult)
      @buildresult_unavailable = true
      return
    end

    monitor_parse_buildresult(buildresult)
    @shown_entries = params.fetch('shown-entries', 50)

    # extract repos
    repohash = {}
    @statushash.each do |repo, arch_hash|
      repohash[repo] = arch_hash.keys.sort!
    end
    @repoarray = repohash.sort
  end

  private

  def project_for_datatable
    case params[:type]
    when 'sibling project'
      @project.siblingprojects
    when 'subproject'
      @project.subprojects.order(:name)
    when 'parent project'
      @project.ancestors.order(:name)
    end
  end
end
