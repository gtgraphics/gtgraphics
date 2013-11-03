class Routing::PageConstraint
  def initialize(type)
    @type = type
  end
  
  def matches?(request)
    path = request.params.fetch(:id) { String.new }
    Page.published.exists?(path: path, embeddable_type: @type)
  end
end