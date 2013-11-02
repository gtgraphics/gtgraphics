class Admin::ImagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_image, only: %i(show edit update destroy download dimensions)

  breadcrumbs do |b|
    b.append Image.model_name.human(count: 2), :admin_images
    b.append translate('breadcrumbs.new', model: Image.model_name.human), :new_admin_image if action_name.in? %w(new create)
    b.append @image.title, [:admin, @image] if action_name.in? %w(show edit update)
    b.append translate('breadcrumbs.edit', model: Image.model_name.human), [:edit, :admin, @image] if action_name.in? %w(edit update)
  end

  def index
    @images = Image.with_translations(I18n.locale).order(Image::Translation.arel_table[:title])
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
    send_file @image.asset.path, filename: @image.virtual_file_name, content_type: @image.content_type, disposition: :attachment
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