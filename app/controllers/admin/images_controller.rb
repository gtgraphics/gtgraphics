class Admin::ImagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_image, only: %i(show edit update destroy)

  def index
    @images = Image.all
    respond_with @images
  end

  def new
    @image = Image.new
    respond_with @image
  end

  def create
    @image = Image.create(image_params)
    respond_with @image
  end

  def show
    respond_with @image
  end

  def edit
    respond_with @image
  end

  def update
    @image.update(image_params)
    respond_with @image
  end

  def destroy
    @image.destroy
    respond_with @image
  end

  private
  def load_image
    @image = Image.find(params[:id])
  end
end