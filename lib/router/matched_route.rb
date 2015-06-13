module Router
  class MatchedRoute
    attr_reader :route, :params

    def initialize(route, params = {})
      @route = route
      @params = params
    end
  end
end
