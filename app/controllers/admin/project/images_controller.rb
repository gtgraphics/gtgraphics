class Admin::Project::ImagesController < Admin::ApplicationController
  before_action :load_project
  before_action :load_project_image, only: %i(move_up move_down destroy)

  def move_up
    @project_image.move_higher
    respond_with :admin, @project, @project_image
  end

  def move_down
    @project_image.move_lower
    respond_with :admin, @project, @project_image
  end

  def destroy
    @project_image.destroy
    respond_with :admin, @project, @project_image, location: [:admin, @project]
  end

  private
  def load_project
    @project = Project.find(params[:project_id])
  end

  def load_project_image
  end
end