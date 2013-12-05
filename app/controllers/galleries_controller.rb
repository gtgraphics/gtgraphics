class GalleriesController < PagesController
  load_embedded :gallery

  def show
    @image_pages = @page.children_with_embedded(:images).published.menu_items.with_translations
    respond_with_page
  end
end