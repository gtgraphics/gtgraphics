class GalleriesController < PagesController
  before_action :load_gallery

  private
  def load_gallery
    @gallery = @page.embeddable
  end
end