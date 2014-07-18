class Admin::AttachmentsController < Admin::ApplicationController
  respond_to :html

  before_action :load_attachment, only: %i(show edit update destroy download convert_to_image)

  breadcrumbs do |b|
    b.append Attachment.model_name.human(count: 2), :admin_attachments
    b.append translate('breadcrumbs.upload', model: Attachment.model_name.human), :new_admin_attachment if action_name.in? %w(new create)
    b.append translate('breadcrumbs.edit', model: Attachment.model_name.human), [:edit, :admin, @attachment] if action_name.in? %w(edit update)
  end

  def index
    @attachments = Attachment.with_translations_for_current_locale \
                             .sort(params[:sort], params[:direction]).page(params[:page])
    respond_with :admin, @attachments
  end

  def new
    @attachment = Attachment.new
    @attachment.translations.build(locale: I18n.locale)
    respond_with :admin, @attachment
  end

  def create
    @attachment = Attachment.create(attachment_params)
    flash_for @attachment
    respond_with :admin, @attachment, location: :admin_attachments
  end

  def edit
    respond_with :admin, @attachment
  end

  def update
    @attachment.update(attachment_params)
    flash_for @attachment
    respond_with :admin, @attachment, location: :admin_attachments
  end

  def destroy
    @attachment.destroy
    flash_for @attachment
    respond_with :admin, @attachment, location: :admin_attachments
  end

  def destroy_multiple
    attachment_ids = Array(params[:attachment_ids])
    Attachment.destroy_all(id: attachment_ids)
    flash_for Attachment, :destroyed, multiple: true
    respond_to do |format|
      format.html { redirect_to :admin_attachments }
    end
  end

  def download
    send_file @attachment.asset.path, filename: @attachment.virtual_filename, content_type: @attachment.content_type, disposition: :attachment, x_sendfile: true
  end

  def convert_to_image
    Attachment.transaction do
      @image = @attachment.to_image
      @image.save!
      @attachment.destroy!
    end
    respond_to do |format|
      format.html { redirect_to [:admin, @image] }
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