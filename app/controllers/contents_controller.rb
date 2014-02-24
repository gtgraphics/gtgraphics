class ContentsController < PagesController
  embeds :content

  def show
    @content_pages = @page.children.menu_items.accessible_by(current_ability)
    respond_with_page
  end
end