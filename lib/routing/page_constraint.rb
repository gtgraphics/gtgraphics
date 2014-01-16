class Routing::PageConstraint
  def initialize(type)
    @type = type
  end
  
  def matches?(request)
    path = request.params.fetch(:path) { String.new }
    Page.exists?(path: path, embeddable_type: @type)
  end
end