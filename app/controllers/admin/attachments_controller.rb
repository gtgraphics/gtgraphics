class Admin::AttachmentsController < Admin::ApplicationController
  respond_to :html

  before_action :load_attachment, only: %i(show edit update destroy download move_to_images)

  breadcrumbs do |b|
    b.append Attachment.model_name.human(count: 2), :admin_attachments
    b.append translate('breadcrumbs.new', model: Attachment.model_name.human), :new_admin_attachment if action_name.in? %w(new create)
    b.append @attachment.title, [:admin, @attachment] if action_name.in? %w(show edit update)
    b.append translate('breadcrumbs.edit', model: Attachment.model_name.human), [:edit, :admin, @attachment] if action_name.in? %w(edit update)
  end

  def index
    @attachments = Attachment.with_translations.sort(params[:sort], params[:direction])
    respond_with :admin, @attachments
  end

  def new
    @attachment = Attachment.new
    @attachment.translations.build(locale: I18n.locale)
    respond_with :admin, @attachment
  end

  def create
    @attachment = Attachment.create(attachment_params)
    respond_with :admin, @attachment
  end

  def show
    respond_with :admin, @attachment
  end

  def edit
    respond_with :admin, @attachment
  end

  def update
    @attachment.update(attachment_params)
    respond_with :admin, @attachment
  end

  def destroy
    @attachment.destroy
    respond_with :admin, @attachment
  end

  def destroy_multiple
    attachment_ids = Array(params[:attachment_ids])
    Attachment.destroy_all(id: attachment_ids)
    respond_to do |format|
      format.html { redirect_to :admin_attachments }
    end
  end

  def download
    send_file @attachment.asset.path, filename: @attachment.virtual_file_name, content_type: @attachment.content_type, disposition: :attachment, x_sendfile: true
  end

  def move_to_images
    valid = false
    if @attachment.image?
      @image = Image.new(@attachment.slice(:author_id, :created_at, :updated_at))
      @image.asset = @attachment.asset
      @attachment.translations.each do |attachment_translation|
        @image.translations.build(attachment_translation.slice(:locale, :title, :description, :created_at, :updated_at))
      end
      Image.transaction do
        valid = @image.save and @attachment.destroy
      end
    end
    respond_to do |format|
      format.html do
        if valid
          redirect_to [:admin, @image]
        else
          # TODO flash.alert = 'Could not move attachment to images'
          redirect_to [:admin, @attachment]
        end
      end
    end
  end

  def translation_fields
    translated_locale = params.fetch(:translated_locale)
    @attachment = Attachment.new
    @attachment.translations.build(locale: translated_locale)
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private
  def attachment_params
    params.require(:attachment).permit(:asset, :author_id, translations_attributes: [:_destroy, :id, :locale, :title, :description])
  end

  def load_attachment
    @attachment = Attachment.find(params[:id])
  end
end