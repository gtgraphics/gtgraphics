module ErrorHandlingController
  extend ActiveSupport::Concern

  included do
    unless Rails.application.config.consider_all_requests_local
      rescue_from(ActiveRecord::RecordNotFound) { render_error :not_found }
      rescue_from(ActionController::UnknownFormat) { render_error :not_found }
      rescue_from(ActionController::RoutingError) { render_error :not_found }
      rescue_from CanCan::AccessDenied do |exception|
        # if signed_in?
          @error_message = exception.message
          @attempted_action = exception.action
          @subject = exception.subject
          render_error :unauthorized
        # else
        #   redirect_to admin_sign_in_path
        # end
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