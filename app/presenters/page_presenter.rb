class PagePresenter < ApplicationPresenter
  presents :page

  def permalink
    h.page_permalink_url(page.permalink, locale: nil)
  end
end