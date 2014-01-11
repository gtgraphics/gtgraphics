class PageSitemapsController < ActionController::Base
  include ErrorHandlingController
  
  respond_to :xml

  def show
    pages = Page.published.indexable.includes(:translations)
    @page_sitemap = PageSitemap.new(pages)
    respond_with @page_sitemap
  end
end