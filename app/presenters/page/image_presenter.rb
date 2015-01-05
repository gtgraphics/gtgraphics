class Page::ImagePresenter < Page::ApplicationPresenter
  presents :image_page

  def page
    present object.page # duplication due to eager loading bug
  end

  delegate_presented :image
  delegate :shop_links, to: :image
end
