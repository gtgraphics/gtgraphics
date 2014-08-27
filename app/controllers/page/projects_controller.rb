class Page::ProjectsController < Page::ApplicationController
  before_action :load_project, only: :show
   
  def default
    @images = @project.images
    respond_to do |format|
      format.html { render_page }
    end
  end

  def load_project
    @project = @page.embeddable.project
  end 
end