class Routing::PageConstraint
  def initialize(type)
    @type = "Page::#{type}"
  end
  
  def matches?(request)
    path = request.params.fetch(:id) { String.new }
    Page.exists?(path: path, embeddable_type: @type)
  end
end