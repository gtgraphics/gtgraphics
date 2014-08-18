class Admin::Project::ImagePresenter < Admin::ApplicationPresenter
  include Admin::MovableResourcePresenter

  presents :project_image
  delegate :image, :project, to: :project_image

  self.action_buttons = [:move_up, :move_down, :destroy]


  # Routes

  def show_path
    h.admin_image_path(image)
  end

  def move_down_path
    h.move_down_admin_project_image_path(project, image)
  end

  def move_up_path
    h.move_up_admin_project_image_path(project, image)
  end

  def destroy_path
    h.admin_project_image_path(project, image)
  end
end