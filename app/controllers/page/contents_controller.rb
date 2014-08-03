class Page::ContentsController < Page::ApplicationController
  before_action :load_child_pages, only: :show

  def default
    @child_pages = @child_pages.menu_items
    respond_with_page
  end

  def gallery
    @child_pages = @child_pages.images.preload(embeddable: :image)
    respond_with_page
  end

  private
  def load_child_pages
    @child_pages = @page.children.accessible_by(current_ability).with_translations_for_current_locale
  end
end