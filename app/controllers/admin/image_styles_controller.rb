class Admin::ImageStylesController < Admin::ApplicationController
  respond_to :html

  before_action :load_image
  before_action :load_image_style, only: %i(edit update crop apply_crop destroy)

  breadcrumbs do |b|
    b.append Image.model_name.human(count: 2), :admin_images
    b.append @image.title, [:admin, @image]
    b.append translate('breadcrumbs.new', model: Image::Style.model_name.human), [:new, :admin, @image, :style] if action_name.in? %w(new new_attachment create)
    b.append translate('breadcrumbs.edit', model: Image::Style.model_name.human), edit_admin_image_style_path(@image, @image_style) if action_name.in? %w(edit crop update)
  end

  def new
    if params[:source] == 'attachment'
      @image_style = @image.custom_styles.new(type: 'Image::Style::Attachment')
    else
      @image_style = @image.custom_styles.new(type: 'Image::Style::Variant') do |style|
        style.crop_x = '1'
        style.crop_y = '1'
        style.crop_width = @image.width
        style.crop_height = @image.height
        style.resize_width = @image.width
        style.resize_height = @image.height
      end
    end
    respond_with :admin, @image_style.becomes(Image::Style)
  end

  def create
    @image_style = @image.custom_styles.create(image_style_params)
    flash_for @image_style
    if @image_style.errors.empty?
      if @image_style.attachment?
        location = crop_admin_image_style_path(@image, @image_style)
      else
        location = admin_image_path(@image)
      end
    end
    respond_with :admin, @image_style.becomes(Image::Style), location: location
  end

  def edit
    if @image_style.variant?
      redirect_to crop_admin_image_style_path(@image, @image_style)
    else
      respond_with :admin, @image_style.becomes(Image::Style)
    end
  end

  def update
    raise CanCan::AccessDenied.new(translate('unauthorized.update.image/style/variant'), :update, Image::Style::Variant) if @image_style.variant?
    @image_style.attributes = image_style_params
    @image_style.cropped = false
    @image_style.resized = false
    @image_style.save
    flash_for @image_style
    respond_with :admin, @image_style.becomes(Image::Style), location: [:admin, @image]
  end

  def crop
    @image_style.tap do |style|
      style.crop_x ||= 0
      style.crop_y ||= 0
      style.crop_width ||= style.width
      style.crop_height ||= style.height
      style.resize_width ||= style.width
      style.resize_height ||= style.height
    end
    respond_with :admin, @image_style.becomes(Image::Style)
  end

  def apply_crop
    @image_style.update(image_style_crop_params)
    flash_for @image_style
    respond_with :admin, @image_style.becomes(Image::Style), location: [:admin, @image]
  end

  def destroy
    @image_style.destroy
    flash_for @image_style
    respond_with :admin, @image_style.becomes(Image::Style), location: [:admin, @image]
  end

  private
  def load_image
    @image = Image.find(params[:image_id])
  end

  def load_image_style
    @image_style = @image.custom_styles.find(params[:id])
  end

  IMAGE_CROP_PARAMS = [:cropped, :crop_x, :crop_y, :crop_width, :crop_height, :resized, :resize_width, :resize_height]

  def image_style_params
    image_style_params = params.require(:image_style)
    type = @image_style.try(:type) || image_style_params.fetch(:type)
    permitted_attributes = []
    permitted_attributes << :type if @image_style.try(:new_record?)
    case type
    when 'Image::Style::Variant'
      image_style_crop_params
      permitted_attributes += IMAGE_CROP_PARAMS
    when 'Image::Style::Attachment'
      permitted_attributes << :asset
    end
    image_style_params.permit(*permitted_attributes)
  end

  def image_style_crop_params
    params.require(:image_style).permit(*IMAGE_CROP_PARAMS)
  end
end