class Admin::Image::StylesController < Admin::ApplicationController
  respond_to :html, :js

  before_action :load_image
  before_action :load_image_style, only: %i(show edit update customize apply_customization move_up move_down destroy)

  breadcrumbs do |b|
    b.append ::Image.model_name.human(count: 2), :admin_images
    b.append @image.title, [:admin, @image]
    if action_name.in? %w(new upload)
      b.append translate('breadcrumbs.new', model: ::Image::Style.model_name.human), [:new, :admin, @image, :style]
    end
    if action_name.in? %w(edit crop update)
      b.append translate('breadcrumbs.edit', model: ::Image::Style.model_name.human), edit_admin_image_style_path(@image, @image_style)
    end
  end

  def new
    @image_style = @image.styles.new
    respond_with :admin, @image, @image_style
  end

  def create
    @image_style = @image.styles.new(image_style_params)
    @image_style.asset = @image.asset
    @image_style.original_filename = @image.original_filename
    @image_style.save
    respond_with :admin, @image, @image_style, location: [:admin, @image]
  end

  def edit
    respond_with :admin, @image, @image_style
  end

  def update
    @image_style.update(image_style_params)
    respond_with :admin, @image, @image_style, location: [:admin, @image]
  end

  def upload
    @image_style = @image.styles.new(image_style_upload_params)
    @image_style.save!
    respond_with :admin, @image, @image_style, location: [:admin, @image]
  end

  def customize
    @image_style.tap do |img|
      img.cropped = true if img.cropped.nil?
      img.crop_x ||= 0
      img.crop_y ||= 0
      img.crop_width ||= img.original_width
      img.crop_height ||= img.original_height
      img.resized = false if img.resized.nil?
      img.resize_width ||= img.original_width
      img.resize_height ||= img.original_height
    end
    respond_with :admin, @image, @image_style
  end

  def apply_customization
    Image::Style.transaction do
      @image_style.update(image_style_customization_params)
      @image_style.recreate_assets!
    end
    respond_with :admin, @image, @image_style, location: [:admin, @image]
  end

  def move_up
    @image_style.move_higher
    respond_with :admin, @image, @image_style
  end

  def move_down
    @image_style.move_lower
    respond_with :admin, @image, @image_style
  end

  def destroy
    @image_style.destroy
    respond_with :admin, @image, @image_style, location: [:admin, @image]
  end

  # Batch Processing

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
    image_style_ids = Array(params[:image_style_ids]).map(&:to_i).reject(&:zero?)
    ::Image::Style.accessible_by(current_ability).destroy_all(id: image_style_ids)
    flash_for ::Image, :destroyed, multiple: true
    location = request.referer || admin_image_styles_path(@image)
    respond_to do |format|
      format.html { redirect_to location }
      format.js { redirect_via_turbolinks_to location }
    end
  end
  private :destroy_multiple

  private
  def load_image
    @image = ::Image.find(params[:image_id])
  end

  def load_image_style
    @image_style = @image.styles.find(params[:id])
  end

  def image_style_params
    params.require(:image_style).permit(:title)
  end

  def image_style_upload_params
    params.require(:image_style).permit(:asset)
  end

  def image_style_customization_params
    params.require(:image_style).permit(:cropped, :crop_x, :crop_y, :crop_width, :crop_height, :resized, :resize_width, :resize_height)
  end
end