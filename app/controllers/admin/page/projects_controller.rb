class Admin::Page::ProjectsController < Admin::Page::ApplicationController
  before_action :load_project, only: %i(edit update)

  def new
    @project_page_creation_activity = Admin::ProjectPageCreationActivity.new do |a|
      a.template = "Template::Project".constantize.default
      a.parent_page = @page
    end
    respond_to do |format|
      format.js
    end
  end

  def create
    @project_page_creation_activity = Admin::ProjectPageCreationActivity.new do |a|
      a.attributes = project_page_creation_activity_params
      a.parent_page = @page
      a.execute
    end
    if @project_page_creation_activity.errors.empty?
      if @project_page_creation_activity.pages.many?
        # if many pages have been created, redirect to parent
        page = @project_page_creation_activity.parent_page
      else
        page = @project_page_creation_activity.pages.first
      end
      @location = admin_page_path(page)
    end
    respond_to do |format|
      format.js
    end
  end

  def edit
    respond_with :admin, @page, @project
  end

  def update
    @project.attributes = project_params
    flash_for @page, :updated if @project.save
    respond_with :admin, @page, @project, location: :edit_admin_page_project
  end

  private
  def project_params
    params.require(:page_project).permit(:name, :description, :released_on, :client_name, :client_url)
  end

  def project_page_creation_activity_params
    params.require(:project_page_creation_activity).permit(:project_id_tokens, :template_id, :published)
  end

  def load_project
    @project = @page.embeddable
  end
end