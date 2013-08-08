class Admin::ImagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_album
  before_action :load_image_or_image_album_assignment, only: %i(show edit update destroy download)

  breadcrumbs_for_resource :albums, allow_nil: true
  breadcrumbs_for_resource include_collection: false, if: :album_set?
  breadcrumbs_for_resource unless: :album_set?

  def index
    if @album
      @images = @album.images.joins(:album_assignments).order('album_images.position')
    else
      @images = Image.with_translation
    end
    respond_with :admin, @images
  end

  def new
    if @album
      @image = @album.images.new
    else
      @image = Image.new
    end
    @image.build_translations_for(:de, :en)
    respond_with :admin, @image
  end

  def create
    if @album
      @image = @album.images.create(image_params)
    else
      @image = Image.create(image_params)
    end
    respond_with :admin, @image, location: [:admin, @album, @image].compact
  end

  def show
    @albums = @image.albums.to_a unless @album
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
    if @image_album_assignment
      @image_album_assignment.destroy
    else
      @image.destroy
    end
    respond_with :admin, @image, location: [:admin, @album, :images].compact
  end

  def download
    send_file @image.asset.path, filename: @image.virtual_file_name, content_type: @image.content_type, disposition: :attachment
  end

  def batch
    @image_ids = Array(params[:image_ids]).map(&:to_i).reject(&:zero?)
    if params.key? :destroy
      @batch_action = :destroy_multiple
      Image.destroy_all(id: @image_ids)
    elsif params.key? :move
      @batch_action = :move_multiple
    else
      raise
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render @batch_action }
    end
  end

  private
  def album_set?
    !@album.nil?
  end

  def image_params
    params.require(:image).permit!#.permit(:slug, :title, :caption, :asset, translations_attributes: [:caption, :locale])
  end

  def load_album
    @album = Album.find_by_slug(params[:album_id]) if params[:album_id]
  end

  def load_image_or_image_album_assignment
    @image = Image.find_by_slug!(params[:id])
    @image_album_assignment = @image.album_assignments.find_by_image_id(@image.id) if @album
  end
end