class ErrorsController < ApplicationController
  def unmatched_route
    raise ActionController::RoutingError, "No route matches #{request.path}"
  end
end