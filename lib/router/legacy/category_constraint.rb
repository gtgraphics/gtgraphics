module Router
  module Legacy
    class CategoryConstraint < BaseConstraint
      def matches?(request)
        Routing::Cms::RouteCache.matches? 'Page::Content', path_matcher(request)
      end
    end
  end
end
