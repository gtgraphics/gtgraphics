class Admin::ImageStylesController < Admin::ApplicationController
  respond_to :html

  before_action :load_image
  before_action :load_image_style, only: %i(edit update destroy)

  breadcrumbs do |b|
    b.append Image.model_name.human(count: 2), :admin_images
    b.append @image.title, [:admin, @image]
    b.append translate('breadcrumbs.new', model: Image::Style.model_name.human), [:new, :admin, @image, :style] if action_name.in? %w(new create)
    b.append translate('breadcrumbs.edit', model: Image::Style.model_name.human), edit_admin_image_style_path(@image, @image_style) if action_name.in? %w(edit update)
  end

  def new
    @image_style = @image.custom_styles.new.tap do |s|
      s.crop_x = 0
      s.crop_y = 0
      s.crop_width = @image.width
      s.crop_height = @image.height
      s.resize_width = @image.width
      s.resize_height = @image.height
    end
    respond_with :admin, @image_style
  end

  def create
    @image_style = @image.custom_styles.create(image_style_params)
    respond_with :admin, @image_style, location: [:admin, @image]
  end

  def edit
    respond_with :admin, @image_style
  end

  def update
    @image_style.update(image_style_params)
    respond_with :admin, @image_style, location: [:admin, @image]
  end

  def destroy
    @image_style.destroy
    flash_for @image_style
    respond_with :admin, @image_style, location: [:admin, @image]
  end

  private
  def load_image
    @image = Image.find(params[:image_id])
  end

  def load_image_style
    @image_style = @image.custom_styles.find(params[:id])
  end

  def image_style_params
    params.require(:image_style).permit(:crop_x, :crop_y, :crop_width, :crop_height, :resize_width, :resize_height, :preserve_aspect_ratio)
  end
end