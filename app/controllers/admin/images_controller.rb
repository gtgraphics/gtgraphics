class Admin::ImagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_image, only: %i(show edit update destroy)

  #breadcrumbs do |b|
  #  b.push @image if action_name
  #end

  breadcrumb Image.model_name.human(count: 2), :admin_images
  breadcrumb -> { @image.to_s }, -> { [:admin, @image] }, only: %i(show edit update)

  def index
    @images = Image.order(:title)
    respond_with :admin, @images
  end

  def new
    @image = Image.new
    %w(en de).each do |locale|
      @image.translations.build(locale: locale)
    end
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

  private
  def image_params
    params.require(:image).permit(:slug, :title, :caption, :asset, translations_attributes: [:caption, :locale])
  end

  def load_image
    @image = Image.find_by_slug(params[:id])
  end
end