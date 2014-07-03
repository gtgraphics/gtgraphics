class Admin::Page::ProjectsController < Admin::Page::ApplicationController
  before_action :load_project

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

  def load_project
    @project = @page.embeddable
  end
end