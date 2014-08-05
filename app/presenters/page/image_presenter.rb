class Page::ImagePresenter < ApplicationPresenter
  presents :image_page

  delegate :page, to: :image_page

  def facebook_uri
    super.presence || h.page_permalink_url(page.permalink)
  end

  def facebook_like_button(options = {})
    h.facebook_like_button(self.facebook_uri, options)
  end

  def facebook_comments(options = {})
    h.facebook_comments(self.facebook_uri, options)
  end
end