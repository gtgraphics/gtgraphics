class ContentsController < PagesController
  embeds :content

  def show
    @content_pages = @page.children_with_embedded(:content, :gallery).published.menu_items
    respond_with_page
  end
end