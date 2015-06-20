class Page::ProjectsController < Page::ApplicationController
  routes do
    # TODO: This does not yet work
    get ':image_id', to: :show_image, as: :show_project_image
  end

  before_action :load_project

  def default
    @project_images = @project.project_images.order(:position).includes(:image)
    respond_to do |format|
      format.html { render_page }
    end
  end

  def show_image
    @project_image = @project.project_images
                     .find_by!(position: params[:image_id])
    @image = @project_image.image

    next_project_image = @project_image.higher_item
    @previous_page = show_project_image_path(
      @page.path, next_project_image.position) if next_project_image

    prev_project_image = @project_image.lower_item
    @next_page = show_project_image_path(
      @page.path, prev_project_image.position) if prev_project_image

    respond_to do |format|
      format.html { render layout: 'page/images' }
    end
  end

  private

  def load_project
    @project = @page.embeddable.project
  end
end
