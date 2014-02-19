module ErrorHandlingController
  extend ActiveSupport::Concern

  included do
    unless Rails.application.config.consider_all_requests_local
      rescue_from(Exception) { render_error :internal_server_error }
      rescue_from(ActiveRecord::RecordNotFound) { render_error :not_found }
      rescue_from(ActionController::UnknownFormat) { render_error :not_found }
      rescue_from(ActionController::RoutingError) { render_error :not_found }
      rescue_from(CanCan::AccessDenied) { render_error :unauthorized }
    end
  end

  protected
  def render_error(status)
    respond_to do |format|
      format.html { render "errors/#{status}", status: status }
      format.all { head status }
    end    
  end
end