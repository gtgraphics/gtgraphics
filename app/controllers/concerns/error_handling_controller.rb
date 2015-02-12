module ErrorHandlingController
  extend ActiveSupport::Concern

  included do
    unless Rails.application.config.consider_all_requests_local
      rescue_from ActionController::InvalidAuthenticityToken do
        respond_with_error :bad_request
      end

      rescue_from ActiveRecord::RecordNotFound,
                  ActionController::RoutingError do
        respond_with_error :not_found
      end

      rescue_from ActionController::UnknownFormat do
        respond_with_error :not_found
      end

      rescue_from CanCan::AccessDenied do |exception|
        @error_message = exception.message
        @attempted_action = exception.action
        @subject = exception.subject
        respond_with_error :unauthorized
      end
    end
  end

  protected

  def respond_with_error(status)
    respond_to do |format|
      format.html do
        render "errors/#{status}", layout: 'errors', status: status
      end
      format.all { head status }
    end
  end
end
