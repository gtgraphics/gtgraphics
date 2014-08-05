class Page::ImagePresenter < ApplicationPresenter
  presents :image_page

  delegate :page, to: :image_page

  def facebook_comments(options = {})
    uri = facebook_comments_uri.presence || h.page_permalink_url(page.permalink)
    h.facebook_comments(uri, options)
  end
end