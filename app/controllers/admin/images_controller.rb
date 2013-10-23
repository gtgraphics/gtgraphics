class Admin::ImagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_image, only: %i(show edit update destroy download)

  def index
    @images = Image.order(:title)
    respond_with :admin, @images
  end

  def new
    @image = Image.new
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

  def download
    send_file @image.asset.path, filename: @image.virtual_file_name, content_type: @image.content_type, disposition: :attachment
  end

  private
  def image_params
    params.require(:image).permit! # TODO
  end
end