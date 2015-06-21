class Page::ProjectsController < Page::ApplicationController
  routes do
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

    prev_project_image = @project_image.higher_item
    if prev_project_image
      @previous_page = current_page_path(:show_project_image,
                                         image_id: prev_project_image.position)
    end

    next_project_image = @project_image.lower_item
    if next_project_image
      @next_page = current_page_path(:show_project_image,
                                     image_id: next_project_image.position)
    end

    respond_to do |format|
      format.html { render layout: 'page/images' }
    end
  end

  private

  def load_project
    @project = @page.embeddable.project
  end
end
