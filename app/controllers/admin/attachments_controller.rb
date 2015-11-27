class Admin::AttachmentsController < Admin::ApplicationController
  respond_to :html

  before_action :load_attachment, only: %i(show edit update destroy download convert_to_image)

  breadcrumbs do |b|
    b.append Attachment.model_name.human(count: 2), :admin_attachments
    b.append translate('breadcrumbs.upload', model: Attachment.model_name.human), :new_admin_attachment if action_name.in? %w(new create)
    b.append translate('breadcrumbs.edit', model: Attachment.model_name.human), [:edit, :admin, @attachment] if action_name.in? %w(edit update)
  end

  def index
    @attachments = Attachment.with_translations_for_current_locale.
                              select(Attachment.arel_table[Arel.star], Attachment::Translation.arel_table[:title]).
                              uniq.includes(:author)

    attachment_ids = Array(params[:id])
    if attachment_ids.any?
      if attachment_ids.one?
        return redirect_to safe_params.merge(action: :show)
      else
        @attachments = @attachments.where(id: attachment_id_or_ids)
      end
    else
      @attachments = @attachments.search(params[:query])
      @attachment_search = @attachments.ransack(params[:search])
      @attachment_search.sorts = 'translations_title asc' if @attachment_search.sorts.empty?
      @attachments = @attachment_search.result
    end

    @users = User.order(:first_name, :last_name)

    @attachments.where!(author_id: params[:author_id]) if params[:author_id].present?
    @attachments = @attachments.created(params[:period]) if params[:period].present?
    @attachments.where!(content_type: params[:content_type]) if params[:content_type].present?
    @attachments = @attachments.page(params[:page])

    respond_with :admin, @attachments do |format|
      format.json
    end
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

  def upload
    @attachment = Attachment.new(attachment_upload_params)
    @attachment.author = current_user
    @attachment.save!

    respond_to do |format|
      format.js
    end
  end

  def edit
    respond_with :admin, @attachment
  end

  def update
    @attachment.update(attachment_params)
    flash_for @attachment
    respond_with :admin, @attachment, location: :admin_attachments
  end

  def download
    send_file @attachment.asset.path, filename: @attachment.virtual_filename,
                                      content_type: @attachment.content_type,
                                      disposition: :attachment,
                                      x_sendfile: true
  end

  def destroy
    @attachment.destroy
    flash_for @attachment
    respond_with :admin, @attachment, location: :admin_attachments
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
    attachment_ids = Array(params[:attachment_ids]).map(&:to_i).reject(&:zero?)
    Attachment.accessible_by(current_ability).destroy_all(id: attachment_ids)
    flash_for Attachment, :destroyed, multiple: true
    location = request.referer || admin_attachments_path
    respond_to do |format|
      format.html { redirect_to location }
      format.js { redirect_via_turbolinks_to location }
    end
  end
  private :destroy_multiple # invoked through :batch_process

  private

  def attachment_params
    params.require(:attachment).permit(:asset, :author_id, translations_attributes: [:_destroy, :id, :locale, :title, :description])
  end

  def attachment_upload_params
    params.require(:attachment).permit(:asset)
  end

  def load_attachment
    @attachment = Attachment.find(params[:id])
  end
end
