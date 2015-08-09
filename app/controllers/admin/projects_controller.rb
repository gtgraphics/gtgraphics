class Admin::ProjectsController < Admin::ApplicationController
  respond_to :html

  before_action :load_project, only: %i(show edit update destroy assign_images
                                        attach_images pages)

  breadcrumbs do |b|
    b.append ::Project.model_name.human(count: 2), :admin_projects
    if action_name.in? %w(new create)
      b.append translate('breadcrumbs.new', model: ::Project.model_name.human),
               :new_admin_project
    end
    if @project
      b.append @project.title, [:admin, @project]
      if action_name.in? %w(edit update)
        b.append t('breadcrumbs.edit', model: ::Project.model_name.human),
                 [:edit, :admin, @project]
      end
    end
  end

  def index
    @clients = Client.order(:name)

    @projects = Project.with_translations_for_current_locale
                .eager_load(:client, :author)

    project_ids = Array(params[:id])
    if project_ids.any?
      return redirect_to safe_params.merge(action: :show) if project_ids.one?
      @projects.where!(id: project_ids)
    else
      @projects = @projects.search(params[:query])
      @project_search = @projects.ransack(params[:search])
      @project_search.sorts = 'created_at desc' if @project_search.sorts.empty?
      @projects = @project_search.result(distinct: true)
    end

    client_id = params[:client_id]
    @projects.where!(client_id: client_id) if client_id.present?

    @projects = @projects.page(params[:page])

    respond_with :admin, @projects do |format|
      format.json
    end
  end

  def autocomplete
    query = params[:query]
    if query.present?
      translated_title = Project::Translation.arel_table[:title]
      @projects = Project.search(query).includes(:client, :images)
                  .select(Project.arel_table[Arel.star], translated_title)
                  .order(translated_title.asc)
                  .with_translations_for_current_locale.uniq.limit(3)
    else
      @projects = Project.none
    end
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
    @project_image_assignment_form = Admin::ProjectImageAssignmentForm.new
    @project_image_assignment_form.project = @project

    respond_to do |format|
      format.js
    end
  end

  def attach_images
    @project_image_assignment_form = Admin::ProjectImageAssignmentForm.new
    @project_image_assignment_form.attributes = project_image_assignment_params
    @project_image_assignment_form.project = @project
    @project_image_assignment_form.submit

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
    params.require(:project).permit(:title, :project_type, :url,
                                    :client_name, :released_in)
  end

  def project_params
    params.require(:project).permit(
      :title, :project_type, :url, :client_name, :released_in, :description,
      :author_id, :propagate_changes_to_pages
    )
  end

  def project_image_assignment_params
    params.require(:project_image_assignment_form).permit(:image_id_tokens)
  end
end
