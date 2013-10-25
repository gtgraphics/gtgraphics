class Admin::GalleriesController < Admin::ApplicationController
  respond_to :html

  def index
    @galleries = Gallery.all
    respond_with :admin, @galleries
  end

  def translation_fields
    respond_to do |format|
      format.html
    end
  end
end