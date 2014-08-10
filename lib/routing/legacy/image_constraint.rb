class Routing::Legacy::ImageConstraint < Routing::LegacyConstraint
  def matches?(request)
    Routing::Cms::RouteCache.matches? 'Page::Image', path_matcher(request)
  end
end