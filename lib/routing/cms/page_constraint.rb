class Routing::Cms::PageConstraint
  def initialize(page_type)
    @page_type = page_type
  end
  
  def matches?(request)
    path = request.params[:path] || ''
    Routing::Cms::RouteCache.matches?(@page_type, path)
  end
end