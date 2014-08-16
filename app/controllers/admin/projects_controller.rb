class Admin::ProjectsController < Admin::ApplicationController
  respond_to :html

  before_action :load_project, only: %i(show edit update destroy)

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
    @projects = ::Project.with_translations_for_current_locale.includes(:client, :author).
                        select(::Project.arel_table[Arel.star], Client.arel_table[:name]).
                        uniq.page(params[:page])
    @projects.where!(client_id: params[:client_id]) if params[:client_id].present?
    @project_search = @projects.ransack(params[:search])
    @project_search.sorts = 'translations_title asc' if @project_search.sorts.empty?
    @projects = @project_search.result
    respond_with :admin, @projects
  end

  def new
    @project = ::Project.new
    @project.author = current_user
    respond_to do |format|
      format.js
    end
  end

  def create
    @project = ::Project.new(new_project_params)
    @project.author = current_user
    @project.save
    respond_to do |format|
      format.js
    end
  end

  def show
    @project_images = 
    respond_with :admin, @project
  end

  def edit
    respond_with :admin, @project
  end

  def update
    respond_with :admin, @project, location: [:edit, :admin, @project]
  end

  def destroy
    @project.destroy
    respond_with :admin, @project
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
    params.require(:project).permit(:title, :client_name, :released_in)
  end

  def project_params
    params.require(:project).permit! # TODO
  end
end