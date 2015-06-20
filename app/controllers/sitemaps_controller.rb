class SitemapsController < ActionController::Base
  include Router::ControllerAdapter

  def index
    @sitemaps = Sitemap.all

    respond_to do |format|
      format.xml
    end
  end

  def show
    @sitemap = Sitemap.page(params[:page])
    @pages = @sitemap.pages.includes(:translations)
    @max_page_depth = Sitemap.pages.maximum(:depth).next

    respond_to do |format|
      format.xml
    end
  end
end
