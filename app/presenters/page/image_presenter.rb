class Page::ImagePresenter < Page::ApplicationPresenter
  presents :image_page

  # Facebook Integration

  def facebook_like_button(options = {})
    h.facebook_like_button(page.social_uri, options)
  end

  def facebook_comments(options = {})
    h.facebook_comments(page.social_uri, options)
  end

  def page
    present object.page # duplication due to eager loading bug
  end

  delegate_presented :image
  delegate :shop_links, to: :image
end
