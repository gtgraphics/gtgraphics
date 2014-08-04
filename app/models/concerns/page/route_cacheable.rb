class Page < ActiveRecord::Base
  module RouteCacheable
    extend ActiveSupport::Concern
    
    included do
      before_save :reset_route_cache, if: :path_changed?
      after_destroy :reset_route_cache
    end

    private
    def reset_route_cache
      Routing::Cms::RouteCache.clear
    end
  end
end