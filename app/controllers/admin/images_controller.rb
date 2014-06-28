class Admin::ImagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_image, only: %i(show edit update crop apply_crop uncrop destroy download move_to_attachments dimensions preview)

  breadcrumbs do |b|
    b.append Image.model_name.human(count: 2), :admin_images
    if action_name.in? %w(new create)
      b.append translate('breadcrumbs.new', model: Image.model_name.human), :new_admin_image
    end
    b.append @image.title, [:admin, @image] if action_name.in? %w(show edit update crop apply_crop)
    if action_name.in? %w(edit update crop apply_crop)
      b.append translate('breadcrumbs.edit', model: Image.model_name.human), [:edit, :admin, @image]
    end
  end

  def index
    if image_id_or_ids = params[:id] and image_id_or_ids.present?
      if image_id_or_ids.is_a?(Array)
        @images = Image.where(id: image_id_or_ids)
      else
        redirect_to params.merge(action: :show) and return
      end
    else
      @images = Image.search(params[:query])
    end

    @users = User.order(:first_name, :last_name)
    if params[:author_id]
      @images = @images.where(author_id: params[:author_id])
    end
  
    @images = @images.includes(:translations).with_locales(Globalize.fallbacks) \
                     .includes(:author) \
                     .sort(params[:sort], params[:direction])
                     .page(params[:page]).per(16)
    @images = @images.includes(:custom_styles) if params[:include_styles].to_b
  
    respond_with :admin, @images do |format|
      format.json
    end
  end

  def new
    @image = Image.new
    respond_with :admin, @image
  end

  def create
    @image = Image.create(image_params) do |image|
      image.owner ||= current_user
    end
    flash_for @image, :created if @image.errors.empty?
    respond_with :admin, @image, location: @image.errors.empty? ? [:crop, :admin, @image] : nil
  end

  def show
    @image_styles = @image.custom_styles
    # @tags = @image.tags
    respond_with :admin, @image do |format|
      format.json
    end
  end

  def edit
    respond_with :admin, @image
  end

  def update
    @image.update(image_params)
    flash_for @image
    respond_with :admin, @image
  end

  def crop
    @image.tap do |image|
      image.cropped = true
      image.crop_x ||= 0
      image.crop_y ||= 0
      image.crop_width ||= image.width
      image.crop_height ||= image.height
    end
    respond_with :admin, @image
  end

  def apply_crop
    Image.transaction do
      @image.cropped = true
      @image.attributes = image_crop_params
      @image.save
      @image.asset.reprocess!
    end
    flash_for @image
    respond_with :admin, @image
  end

  def uncrop
    @image.uncrop!
    flash_for @image
    respond_with :admin, @image
  end

  def destroy
    @image.destroy
    flash_for @image
    respond_with :admin, @image
  end

  def batch_process
    if params.key?(:destroy)
      destroy_multiple
    elsif params.key?(:assign_to_gallery)
      image_ids = Array(params[:image_ids]).reject(&:blank?)
      respond_to do |format|
        format.html { redirect_to assign_to_gallery_admin_images_path(image_ids: image_ids) }
      end
    else
      respond_to do |format|
        format.html { head :bad_request }
      end
    end
  end

  def assign_to_gallery
    breadcrumbs.append translate('breadcrumbs.assign_to_gallery', model: Image.model_name.human(count: 2))
    if request.post?
      raise 'sent'
    else
      image_ids = Array(params[:image_ids])
      images = Image.accessible_by(current_ability).find(image_ids)
      if images.empty?
        respond_to do |format|
          format.html { head :bad_request }
        end
      else
        @assignment_activity = ImageGalleryAssignmentActivity.new()
        respond_to do |format|
          format.html
        end
      end
    end
  end

  def dimensions
    if style = params[:style] and Image.attachment_definitions[:asset][:styles].keys.map(&:to_s).include?(style)
      geometry = Paperclip::Geometry.from_file(@image.asset.path(style))
      width = geometry.width.to_i
      height = geometry.height.to_i
    else
      width = @image.width
      height = @image.height
    end
    respond_to do |format|
      format.json { render json: { width: width, height: height } }
    end
  end

  def download
    send_file @image.asset.path, filename: @image.virtual_file_name, content_type: @image.content_type, disposition: :attachment, x_sendfile: true
  end

  def move_to_attachments
    valid = false
    @attachment = Attachment.new(@image.slice(:author_id, :created_at, :updated_at))
    @attachment.asset = @image.asset
    @image.translations.each do |image_translation|
      @attachment.translations.build(image_translation.slice(:locale, :title, :description, :created_at, :updated_at))
    end
    Attachment.transaction do
      valid = @attachment.save and @image.destroy
    end
    respond_to do |format|
      format.html do
        if valid
          redirect_to [:admin, @attachment]
        else
          flash_for Image, :unmovable, alert: true
          redirect_to [:admin, @image]
        end
      end
    end
  end

  def translation_fields
    translated_locale = params.fetch(:translated_locale)
    @image = Image.new
    @image.translations.build(locale: translated_locale)
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private
  def destroy_multiple
    image_ids = Array(params[:image_ids])
    Image.accessible_by(current_ability).destroy_all(id: image_ids)
    flash_for Image, :destroyed, multiple: true
    respond_to do |format|
      format.html { redirect_to :admin_images }
    end
  end

  def load_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:asset, :title, :description, :author_id, :tag_tokens)
  end

  def image_page_embedding_activity_params
    params.require(:image_page_embedding_activity).permit(:parent_page_id)
  end

  def image_crop_params
    params.require(:image).permit(:crop_x, :crop_y, :crop_width, :crop_height)
  end
end