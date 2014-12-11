class Admin::Page::ProjectsController < Admin::Page::ApplicationController
  before_action :load_project, only: %i(edit update)

  def new
    @project_page_creation_form = Admin::ProjectPageCreationForm.new do |a|
      a.template = "Template::Project".constantize.default
      a.parent_page = @page
    end
    respond_to do |format|
      format.js
    end
  end

  def create
    @project_page_creation_form = Admin::ProjectPageCreationForm.new do |a|
      a.attributes = project_page_creation_form_params
      a.parent_page = @page
      a.submit
    end
    if @project_page_creation_form.errors.empty?
      @location = admin_page_path(@project_page_creation_form.parent_page)
    end
    respond_to do |format|
      format.js
    end
  end

  private
  def load_project
    @project = @page.embeddable
  end

  def project_params
    params.require(:page_project).permit(:name, :description, :released_on, :client_name, :client_url)
  end

  def project_page_creation_form_params
    params.require(:project_page_creation_form).permit(:project_id_tokens, :template_id, :published)
  end
end