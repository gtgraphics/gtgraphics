class Routing::Legacy::CategoryConstraint < Routing::LegacyConstraint
  def matches?(request)
    Routing::Cms::RouteCache.matches? 'Page::Content', path_matcher(request)
  end
end