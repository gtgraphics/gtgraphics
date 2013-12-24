class Admin::ImageStylesController < Admin::ApplicationController
  respond_to :html

  before_action :load_image
  before_action :load_image_style, only: %i(edit update destroy)

  def new
    @image_style = @image.styles.new
    respond_with :admin, @image_style
  end

  def create
    @image_style = @image.styles.create(image_style_params)
    respond_with :admin, @image_style, location: [:admin, @image]
  end

  def edit
    respond_with :admin, @image_style
  end

  def update
    @image_style.update(image_style_params)
    respond_with :admin, @image_style, location: [:admin, @image]
  end

  def destroy
    @image_style.destroy
    flash_for @image_style
    respond_with :admin, @image_style, location: [:admin, @image]
  end

  private
  def load_image
    @image = Image.find(params[:image_id])
  end

  def load_image_style
    @image_style = @image.styles.find(params[:id])
  end

  def image_style_params
    params.require(:image_style).permit! # TODO
  end
end