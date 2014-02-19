class Routing::Legacy::ImageConstraint
  def matches?(request)
    Page.images.exists?(slug: request.params[:slug])
  end
end