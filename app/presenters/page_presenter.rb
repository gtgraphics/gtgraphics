class PagePresenter < ApplicationPresenter
  presents :page

  def embeddable
    present super
  end

  def permalink
    h.page_permalink_url(page.permalink, locale: nil)
  end

  def social_uri
    page.metadata.fetch(:social_uri) { permalink }
  end
end
