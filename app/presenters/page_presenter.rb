class PagePresenter < ApplicationPresenter
  presents :page

  def embeddable
    present super, with: "#{embeddable_type}Presenter".constantize
  end

  def permalink
    h.page_permalink_url(page.permalink, locale: nil)
  end
end