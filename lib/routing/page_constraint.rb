class Routing::PageConstraint
  def initialize(type = nil)
    @type = type
  end
  
  def matches?(request)
    path = request.params.fetch(:path) { String.new }
    if @type
      Page.exists?(path: path, embeddable_type: @type)
    else
      Page.exists?(path: path)
    end
  end
end