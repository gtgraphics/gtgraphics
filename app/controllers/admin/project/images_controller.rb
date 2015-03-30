class Admin::Project::ImagesController < Admin::ApplicationController
  respond_to :html, :js

  before_action :load_project
  before_action :load_project_image, only: %i(move_up move_down destroy)

  def upload
    Project::Image.transaction do
      image = ::Image.new(image_upload_params)
      image.author = current_user
      image.save!
      @project_image = @project.project_images.create!(image: image)
      @project_image.with_lock do
        @project_image.update_column(:position, @project.project_images.count)
      end
    end
    respond_to do |format|
      format.js { render :refresh_table }
    end
  end

  def move_up
    @project_image.with_lock do
      @project_image.move_higher
    end
    respond_with :admin, @project, @project_image, location: [:admin, @project] do |format|
      format.js { render :refresh_table }
    end
  end

  def move_down
    @project_image.with_lock do
      @project_image.move_lower
    end
    respond_with :admin, @project, @project_image, location: [:admin, @project] do |format|
      format.js { render :refresh_table }
    end
  end

  def destroy
    @project_image.destroy
    respond_with :admin, @project, @project_image, location: [:admin, @project] do |format|
      format.js { render :refresh_table }
    end
  end

  def batch_process
    if params.key? :destroy
      destroy_multiple
    else
      respond_to do |format|
        format.any { head :bad_request }
      end
    end
  end

  def destroy_multiple
    project_image_ids = Array(params[:project_image_ids]).map(&:to_i).reject(&:zero?)
    ::Project::Image.accessible_by(current_ability).destroy_all(id: project_image_ids)
    respond_to do |format|
      format.html { redirect_to [:admin, @project] }
      format.js { render :refresh_table }
    end
  end
  private :destroy_multiple

  private

  def load_project
    @project = ::Project.find(params[:project_id])
  end

  def load_project_image
    @project_image = @project.project_images.find_by!(id: params[:id])
  end

  def image_upload_params
    params.require(:image).permit(:asset)
  end
end
