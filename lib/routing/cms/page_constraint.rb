class Routing::Cms::PageConstraint
  include ActiveSupport::Benchmarkable

  def initialize(page_type)
    @page_type = page_type
  end

  def matches?(request)
    path = request.params[:path] || ''
    benchmark "Find Route: /#{path} (#{@page_type})" do
      # Page.where(embeddable_type: @page_type).published.exists?(path: path)
      Routing::Cms::RouteCache.matches?(@page_type, path)
    end
  end

  private

  def logger
    Rails.logger
  end
end
