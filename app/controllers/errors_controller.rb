class ErrorsController < ActionController::Base
  include BreadcrumbController
  include ErrorHandlingController
  include FlashableController
  include RouteHelper

  def unmatched_route
    raise ActionController::RoutingError, "No route matches #{request.path}"
  end
end