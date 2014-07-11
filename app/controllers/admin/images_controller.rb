class Admin::ImagesController < Admin::ApplicationController
  layout :determine_layout

  respond_to :html

  before_action :load_image, only: %i(show edit update customize apply_customization destroy download move_to_attachments dimensions preview)

  breadcrumbs do |b|
    b.append ::Image.model_name.human(count: 2), :admin_images
    if action_name.in? %w(new create)
      b.append translate('breadcrumbs.new', model: ::Image.model_name.human), :new_admin_image
    end
    b.append @image.title, [:admin, @image] if action_name.in? %w(show edit update crop apply_crop)
    if action_name.in? %w(edit update crop apply_crop)
      b.append translate('breadcrumbs.edit', model: ::Image.model_name.human), [:edit, :admin, @image]
    end
  end

  def index
    if image_id_or_ids = params[:id] and image_id_or_ids.present?
      if image_id_or_ids.is_a?(Array)
        @images = ::Image.where(id: image_id_or_ids)
      else
        redirect_to params.merge(action: :show) and return
      end
    else
      @images = ::Image.search(params[:query])
    end

    @users = User.order(:first_name, :last_name)
    if params[:author_id]
      @images = @images.where(author_id: params[:author_id])
    end
  
    @images = @images.includes(:translations).with_locales(Globalize.fallbacks) \
                     .includes(:author) \
                     .sort(params[:sort], params[:direction])
                     .page(params[:page]).per(25)
    @images = @images.includes(:custom_styles) if params[:include_styles].to_b
    @images = @images.created(params[:period]) if params[:period]
    @images = @images.where(content_type: params[:content_type]) if params[:content_type]
  
    respond_with :admin, @images do |format|
      format.json
    end
  end

  def show
    @image_styles = @image.custom_styles
    respond_with :admin, @image do |format|
      format.json
    end
  end

  def upload
    @image = ::Image.new
    @image.asset = image_upload_params[:asset]
    @image.author = current_user
    @image.save!
    respond_to do |format|
      format.js
    end
  end

  def edit
    respond_with :admin, @image
  end

  def update
    @image.update(image_params)
    flash_for @image
    respond_with :admin, @image do |format|
      format.js
    end
  end

  def customize
    @image.tap do |img|
      img.cropped = true if img.cropped.nil?
      img.crop_x ||= 0
      img.crop_y ||= 0
      img.crop_width ||= img.width
      img.crop_height ||= img.height
      img.resized = false if img.resized.nil?
      img.resize_width ||= img.width
      img.resize_height ||= img.height
    end
    respond_to do |format|
      format.js
    end
  end

  def apply_customization
    Image.transaction do
      @image.update(image_customization_params)
      @image.recreate_assets!
    end
    respond_to do |format|
      format.js 
    end
  end

  def destroy
    @image.destroy
    flash_for @image
    respond_with :admin, @image, location: request.referer || :admin_images
  end

  def dimensions
    if style = params[:style] and ::Image.attachment_definitions[:asset][:styles].keys.map(&:to_s).include?(style)
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
    send_file @image.asset.custom.path, filename: @image.virtual_file_name,
                                        content_type: @image.content_type,
                                        disposition: :attachment,
                                        x_sendfile: true
  end

  # Batch Processing

  def batch_process
    if params.key? :destroy
      destroy_multiple
    elsif params.key? :search
      search
    elsif params.key? :assign_owner
      assign_owner
    else
      respond_to do |format|
        format.any { head :bad_request }
      end
    end
  end

  def search
    location = admin_images_path(query: params[:query])
    respond_to do |format|
      format.html { redirect_to location }
      format.js { redirect_via_turbolinks_to location }
    end
  end
  private :search

  def destroy_multiple
    image_ids = Array(params[:image_ids]).map(&:to_i).reject(&:zero?)
    ::Image.accessible_by(current_ability).destroy_all(id: image_ids)
    flash_for ::Image, :destroyed, multiple: true
    location = request.referer || admin_images_path
    respond_to do |format|
      format.html { redirect_to location }
      format.js { redirect_via_turbolinks_to location }
    end
  end
  private :destroy_multiple

  def assign_owner
    @image_owner_assignment_activity = Admin::ImageOwnerAssignmentActivity.new
    @image_owner_assignment_activity.image_ids = Array(params[:image_ids])
    @image_owner_assignment_activity.author = current_user
    respond_to do |format|
      format.js { render 'assign_owner' }
    end
  end
  private :assign_owner

  def associate_owner
    @image_owner_assignment_activity = Admin::ImageOwnerAssignmentActivity.execute(image_owner_assignment_params)
    respond_to do |format|
      format.js
    end
  end

  private
  def determine_layout
    if action_name.in? %w(new create edit update)
      'admin/image_editor'
    else
      'admin/images'
    end
  end

  def load_image
    @image = ::Image.find(params[:id])
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

  def image_customization_params
    params.require(:image).permit(:cropped, :crop_x, :crop_y, :crop_width, :crop_height, :resized, :resize_width, :resize_height)
  end

  def image_upload_params
    params.require(:image).permit(:asset)
  end

  def image_owner_assignment_params
    params.require(:image_owner_assignment).permit(:author_id, image_ids: [])
  end
end