class Admin::ImagesController < Admin::ApplicationController
  include Admin::TaggableController

  respond_to :html

  before_action :load_image, only: %i(show edit update customize
                                      apply_customization destroy download
                                      convert_to_attachment dimensions preview
                                      pages)

  breadcrumbs do |b|
    b.append ::Image.model_name.human(count: 2), :admin_images
    if action_name.in? %w(new create)
      b.append translate('breadcrumbs.new', model: ::Image.model_name.human),
               :new_admin_image
    end
    if action_name.in? %w(show edit update crop apply_crop)
      b.append @image.title, [:admin, @image]
    end
    if action_name.in? %w(edit update crop apply_crop)
      b.append translate('breadcrumbs.edit', model: ::Image.model_name.human),
               [:edit, :admin, @image]
    end
  end

  def index
    @images = Image.with_translations_for_current_locale.eager_load(:author)

    image_ids = Array(params[:id])
    if image_ids.one?
      redirect_to admin_image_path(image_ids.first, format: params[:format])
      return
    elsif image_ids.many?
      @images.where!(id: image_ids)
    else
      @images = @images.search(params[:query])
      @image_search = @images.ransack(params[:search])
      @image_search.sorts = 'created_at desc' if @image_search.sorts.empty?
      @images = @image_search.result(distinct: true)
    end

    @users = User.order(:first_name, :last_name)
    @tags = Image.available_tags.popularity

    @images.includes!(:styles) if params[:include_styles].to_b
    @images.where!(author_id: params[:author_id]) if params[:author_id].present?
    @images = @images.tagged(params[:tag])
    @images = @images.page(params[:page])

    respond_with :admin, @images do |format|
      format.json
    end
  end

  def autocomplete
    query = params[:query]
    if query.present?
      translated_title = Image::Translation.arel_table[:title]
      @images = Image.search(query).with_translations_for_current_locale.uniq
                .select(Image.arel_table[Arel.star], translated_title)
                .order(translated_title.asc).limit(3)
    else
      @images = Image.none
    end
    respond_to do |format|
      format.json
    end
  end

  def show
    @tags = @image.tags.order(:label)
    respond_with :admin, @image do |format|
      format.json
    end
  end

  def upload
    @image = ::Image.new(image_upload_params)
    tags = Tag.where(label: params[:tag])
    tags.each { |tag| @image.taggings.find_or_initialize_by(tag: tag) }
    @image.save!

    respond_to do |format|
      format.js
    end
  end

  def edit
    @image.propagate_changes_to_pages = true
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
      img.crop_width ||= img.original_width
      img.crop_height ||= img.original_height
      img.resized = false if img.resized.nil?
      img.resize_width ||= img.original_width
      img.resize_height ||= img.original_height
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
    respond_with :admin, @image, location: :admin_images
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
    send_file @image.asset.custom.path, filename: @image.virtual_filename,
                                        content_type: @image.content_type,
                                        disposition: :attachment,
                                        x_sendfile: true
  end

  def pages
    @pages = @image.pages.with_translations_for_current_locale
    respond_to do |format|
      format.js
    end
  end


  # Batch Processing

  def batch_process
    if params.key? :destroy
      destroy_multiple
    elsif params.key? :assign_owner
      assign_owner
    elsif params.key? :convert_to_attachment
      convert_to_attachment
    elsif params.key? :assign_tags
      assign_tags
    else
      respond_to do |format|
        format.any { head :bad_request }
      end
    end
  end

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
  private :destroy_multiple # invoked through :batch_process


  # Owner Assignment

  def assign_owner
    @image_owner_assignment_form = Admin::ImageOwnerAssignmentForm.new
    @image_owner_assignment_form.image_ids = Array(params[:image_ids])
    @image_owner_assignment_form.author = current_user

    respond_to do |format|
      format.js { render :assign_owner }
    end
  end
  private :assign_owner # invoked through :batch_process

  def associate_owner
    @image_owner_assignment_form = Admin::ImageOwnerAssignmentForm.submit(image_owner_assignment_params)

    respond_to do |format|
      format.js
    end
  end


  # Attachment Conversion

  def convert_to_attachment
    Image.transaction do
      @attachment = @image.to_attachment
      @attachment.save!
      @image.destroy!
    end
    respond_to do |format|
      format.html { redirect_to :admin_attachments }
    end
  end

  private

  def load_image
    @image = ::Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(
      :asset, :title, :description, :author_id, :tag_tokens, :propagate_changes_to_pages,
      *Image.available_shop_providers.map { |provider| :"#{provider}_url" }
    )
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
