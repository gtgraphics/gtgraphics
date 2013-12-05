class ContentsController < PagesController
  load_embedded :content

  def show
    @content_pages = @page.children_with_embedded(:content, :gallery).published.menu_items.with_translations
    respond_with_page
  end
end