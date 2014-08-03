class Routing::Cms::PageConstraint
  def initialize(type)
    @type = type
  end
  
  def matches?(request)
    path = request.params[:path] || ''
    if @type
      Page.exists?(path: path, embeddable_type: @type)
    else
      Page.exists?(path: path)
    end
  end
end