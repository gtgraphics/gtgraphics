Router::ErrorHandler.configure do |config|
  config.rescue_from 'ActiveRecord::RecordNotFound', with: :not_found
  config.rescue_from 'ActionController::UnknownFormat', with: :not_found
  config.rescue_from 'ActionController::RoutingError', with: :not_found
  config.rescue_from 'ActionController::InvalidAuthenticityToken',
                     with: :bad_request
  config.rescue_from 'CanCan::AccessDenied', with: :unauthorized
  config.rescue_from 'MaintainableController::Maintained',
                     with: :service_unavailable
end
