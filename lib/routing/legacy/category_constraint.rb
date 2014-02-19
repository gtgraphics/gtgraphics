class Routing::Legacy::CategoryConstraint
  def matches?(request)
    slug = request.params[:slug].split(',').first
    Page.contents.exists?(slug: slug)
  end
end