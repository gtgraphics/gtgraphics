class Page::ProjectsRouter < Page::ApplicationRouter
  def initialize
    super
    get ':image_id', action: :show_image, as: :show_project_image
  end
end
