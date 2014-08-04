module ErrorHandlingController
  extend ActiveSupport::Concern

  included do
    unless Rails.application.config.consider_all_requests_local
      rescue_from ActionController::InvalidAuthenticityToken do
        render_error :bad_request
      end

      rescue_from ActiveRecord::RecordNotFound do
        render_error :not_found
      end
      
      rescue_from ActionController::UnknownFormat do
        render_error :not_found
      end
      
      rescue_from CanCan::AccessDenied do |exception|
        @error_message = exception.message
        @attempted_action = exception.action
        @subject = exception.subject
        render_error :unauthorized
      end
    end
  end

  protected
  def render_error(status)
    respond_to do |format|
      format.html { render "errors/#{status}", layout: 'errors', status: status }
      format.all { head status }
    end    
  end
end