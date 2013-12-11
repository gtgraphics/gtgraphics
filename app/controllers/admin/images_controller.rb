class Admin::ImagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_image, only: %i(show edit update destroy download move_to_attachments dimensions)

  breadcrumbs do |b|
    b.append Image.model_name.human(count: 2), :admin_images
    b.append translate('breadcrumbs.new', model: Image.model_name.human), :new_admin_image if action_name.in? %w(new create)
    b.append @image.title, [:admin, @image] if action_name.in? %w(show edit update)
    b.append translate('breadcrumbs.edit', model: Image.model_name.human), [:edit, :admin, @image] if action_name.in? %w(edit update)
  end

  def index
    @images = Image.with_translations.order(Image::Translation.arel_table[:title])
    respond_with :admin, @images
  end

  def new
    @image = Image.new
    @image.translations.build(locale: I18n.locale)
    respond_with :admin, @image
  end

  def create
    @image = Image.create(image_params)
    respond_with :admin, @image
  end

  def show
    respond_with :admin, @image
  end

  def edit
    respond_with :admin, @image
  end

  def update
    @image.update(image_params)
    respond_with :admin, @image
  end

  def destroy
    @image.destroy
    respond_with :admin, @image
  end

  def destroy_multiple
    image_ids = Array(params[:image_ids])
    Image.destroy_all(id: image_ids)
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
          # TODO flash.alert = 'Could not move attachment to images'
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
  def load_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit! # TODO
  end
end