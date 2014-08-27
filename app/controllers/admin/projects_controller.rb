class Admin::ProjectsController < Admin::ApplicationController
  respond_to :html

  before_action :load_project, only: %i(show edit update destroy assign_images attach_images pages)

  breadcrumbs do |b|
    b.append ::Project.model_name.human(count: 2), :admin_projects
    if action_name.in? %w(new create)
      b.append translate('breadcrumbs.new', model: ::Project.model_name.human), :new_admin_project
    end
    if @project
      b.append @project.title, [:admin, @project]
      if action_name.in? %w(edit update)
        b.append translate('breadcrumbs.edit', model: ::Project.model_name.human), [:edit, :admin, @project]
      end
    end
  end

  def index
    @clients = Client.order(:name)

    @projects = Project.with_translations_for_current_locale.
                      includes(:client, :author).
                      select(Project.arel_table[Arel.star], Project::Translation.arel_table[:title]).
                      uniq.includes(:author)

    project_ids = Array(params[:id])
    if project_ids.any?
      if project_ids.one?
        redirect_to params.merge(action: :show) and return        
      else
        @projects = @projects.where(id: project_ids)
      end
    else
      query = params[:query]
      @projects = @projects.search(query)
      @project_search = @projects.ransack(params[:search])
      if @project_search.sorts.empty?
        if query.blank? and request.format.json?
          @project_search.sorts = 'created_at desc'
        else
          @project_search.sorts = 'translations_title asc'
        end
      end
      @projects = @project_search.result
    end

    @projects.where!(client_id: params[:client_id]) if params[:client_id].present?
    @projects = @projects.page(params[:page])

    respond_with :admin, @projects do |format|
      format.json
    end
  end

  def autocomplete
    @projects = Project.search(params[:query]).includes(:client, :images).
                        order(Project::Translation.arel_table[:title]).
                        with_translations_for_current_locale.uniq.limit(3)
    respond_to do |format|
      format.json
    end
  end

  def new
    @project = ::Project.new
    @project.author = current_user
    @project.released_in = Date.today.year
    respond_to do |format|
      format.js
    end
  end

  def create
    @project = ::Project.new(new_project_params)
    @project.author = current_user
    @project.save
    flash_for @project
    respond_to do |format|
      format.js
    end
  end

  def show
    @project_images = @project.project_images.includes(:image)
    respond_with :admin, @project do |format|
      format.json
    end
  end

  def edit
    respond_with :admin, @project
  end

  def update
    @project.update(project_params)
    flash_for @project
    respond_with :admin, @project, location: [:edit, :admin, @project]
  end

  def destroy
    @project.destroy
    flash_for @project
    respond_with :admin, @project
  end

  def assign_images
    @project_image_assignment_activity = Admin::ProjectImageAssignmentActivity.new
    @project_image_assignment_activity.project = @project
    respond_to do |format|
      format.js
    end
  end

  def attach_images
    @project_image_assignment_activity = Admin::ProjectImageAssignmentActivity.new(project_image_assignment_params)
    @project_image_assignment_activity.project = @project
    @project_image_assignment_activity.execute
    respond_to do |format|
      format.js
    end
  end

  def pages
    @pages = @project.pages.with_translations_for_current_locale
    respond_to do |format|
      format.js
    end
  end

  # Batch Processing

  def batch_process
    if params.key? :destroy
      destroy_multiple
    else
      respond_to do |format|
        format.any { head :bad_request }
      end
    end
  end

  def destroy_multiple
    project_ids = Array(params[:project_ids]).map(&:to_i).reject(&:zero?)
    ::Project.accessible_by(current_ability).destroy_all(id: project_ids)
    flash_for ::Project, :destroyed, multiple: true
    location = request.referer || admin_images_path
    respond_to do |format|
      format.html { redirect_to location }
      format.js { redirect_via_turbolinks_to location }
    end
  end
  private :destroy_multiple # invoked through :batch_process

  private
  def load_project
    @project = ::Project.find(params[:id])
  end

  def new_project_params
    params.require(:project).permit(:title, :project_type, :url, :client_name, :released_in)
  end

  def project_params
    params.require(:project).permit(:title, :project_type, :url, :client_name, :released_in, :description, :author_id)
  end

  def project_image_assignment_params
    params.require(:project_image_assignment_activity).permit(:image_id_tokens)
  end
end