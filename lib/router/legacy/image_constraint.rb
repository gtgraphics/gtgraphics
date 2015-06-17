module Router
  module Legacy
    class ImageConstraint < BaseConstraint
      def matches?(request)
        Routing::Cms::RouteCache.matches? 'Page::Image', path_matcher(request)
      end
    end
  end
end
