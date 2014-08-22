class Page::ProjectsController < Page::ApplicationController
  before_action :load_project, only: :show
  
  def load_project
    @project = @page.embeddable.project
  end
end