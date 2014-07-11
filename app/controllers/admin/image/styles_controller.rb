class Admin::Image::StylesController < Admin::ApplicationController
  layout 'admin/image_editor'

  respond_to :html

  before_action :load_image
  before_action :load_image_style, only: %i(show edit update crop apply_crop destroy)

  breadcrumbs do |b|
    b.append ::Image.model_name.human(count: 2), :admin_images
    b.append @image.title, [:admin, @image]
    b.append ::Image::Style.model_name.human(count: 2), [:admin, @image, :styles]
    if action_name.in? %w(new new_attachment create)
      b.append translate('breadcrumbs.new', model: ::Image::Style.model_name.human), [:new, :admin, @image, :style]
    end
    if action_name.in? %w(edit crop update)
      b.append translate('breadcrumbs.edit', model: ::Image::Style.model_name.human), edit_admin_image_style_path(@image, @image_style)
    end
  end

  def index
    @image_styles = @image.custom_styles.with_translations_for_current_locale.page(params[:page]).sort(params[:sort], params[:direction])
    respond_with :admin, @image, @image_styles
  end

  def show
    respond_with :admin, @image, @image_style
  end

  def new
    @image_style = @image.custom_styles.new
    respond_with :admin, @image, @image_style
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
    respond_with :admin, @image_style.becomes(::Image::Style), location: location
  end

  def upload
    @image_style = ::Image::Style.new
    @image_style.asset = image_style_upload_params[:asset]
    @image_style.author = current_user
    @image_style.save!
    respond_to do |format|
      format.js
    end
  end

  def edit
    if @image_style.variant?
      redirect_to crop_admin_image_style_path(@image, @image_style)
    else
      respond_with :admin, @image_style.becomes(::Image::Style)
    end
  end

  def update
    raise CanCan::AccessDenied.new(translate('unauthorized.update.image/style/variant'), :update, ::Image::Style::Variant) if @image_style.variant?
    @image_style.attributes = image_style_params
    @image_style.cropped = false
    @image_style.resized = false
    @image_style.save
    flash_for @image_style
    respond_with :admin, @image_style.becomes(::Image::Style)
  end

  def destroy
    @image_style.destroy
    flash_for @image_style
    respond_with :admin, @image_style.becomes(::Image::Style)
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
    @image_style = @image.custom_styles.find(params[:id])
  end

  IMAGE_CROP_PARAMS = [:cropped, :crop_x, :crop_y, :crop_width, :crop_height, :resized, :resize_width, :resize_height]

  def image_style_params
    image_style_params = params.require(:image_style)
    type = @image_style.try(:type) || image_style_params.fetch(:type)
    permitted_attributes = []
    permitted_attributes << :type unless @image_style.try(:persisted?)
    case type
    when '::Image::Style::Variant'
      image_style_crop_params
      permitted_attributes += IMAGE_CROP_PARAMS
    when '::Image::Style::Attachment'
      permitted_attributes << :asset
    end
    image_style_params.permit(*permitted_attributes)
  end

  def image_style_crop_params
    params.require(:image_style).permit(*IMAGE_CROP_PARAMS)
  end

  def image_style_upload_params
    params.require(:image_style).permit(:asset)
  end
end