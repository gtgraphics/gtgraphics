class ImagesController < ApplicationController
  respond_to :html

  before_action :set_image, only: [:show, :edit, :update, :destroy]

  def index
    @images = Image.all
    respond_with @images
  end

  def show
    respond_with @image
  end

  def new
    @image = Image.new
    respond_with @image
  end

  def create
    @image = Image.create(image_params)
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
  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:title, :slug, :description)
  end
end
