class GalleriesController < PagesController
  before_action :load_gallery

  def show
    @image_pages = @page.children_with_embedded(:images).published.menu_items
    super
  end

  private
  def load_gallery
    @gallery = @page.embeddable
  end
end