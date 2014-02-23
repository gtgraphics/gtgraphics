class Admin::ImagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_image, only: %i(show edit update crop apply_crop uncrop destroy download move_to_attachments dimensions context_menu)

  breadcrumbs do |b|
    b.append Image.model_name.human(count: 2), :admin_images
    b.append translate('breadcrumbs.new', model: Image.model_name.human), :new_admin_image if action_name.in? %w(new create)
    b.append @image.title, [:admin, @image] if action_name.in? %w(show edit update crop apply_crop)
    b.append translate('breadcrumbs.edit', model: Image.model_name.human), [:edit, :admin, @image] if action_name.in? %w(edit update crop apply_crop)
  end

  def index
    @images = Image.with_translations.includes(:author, :custom_styles).sort(params[:sort], params[:direction]).page(params[:page]).per(16)
    respond_with :admin, @images
  end

  def new
    @image = Image.new
    @image.translations.build(locale: I18n.locale)
    @image_page_embedding_activity = ImagePageEmbeddingActivity.new
    respond_with :admin, @image
  end

  def create
    @image = Image.create(image_params)
    flash_for @image
    #@image_page_embedding_activity = ImagePageEmbeddingActivity.new(image_page_embedding_activity_params)
    #if @image_page_embedding_activity.valid? and @image.save
    #  @image_page_embedding_activity.image = image
    #  flash_for @image
    #end
    respond_with :admin, @image
  end

  def show
    @image_styles = @image.custom_styles
    respond_with :admin, @image
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

  def destroy_multiple
    image_ids = Array(params[:image_ids])
    Image.destroy_all(id: image_ids)
    flash_for Image, :destroyed, multiple: true
    respond_to do |format|
      format.html { redirect_to :admin_images }
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

  def context_menu
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private
  def load_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:asset, :author_id, translations_attributes: [:id, :locale, :_destroy, :title, :description])
  end

  def image_page_embedding_activity_params
    params.require(:image_page_embedding_activity).permit(:parent_page_id)
  end

  def image_crop_params
    params.require(:image).permit(:crop_x, :crop_y, :crop_width, :crop_height)
  end
end