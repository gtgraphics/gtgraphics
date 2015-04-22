module ErrorHandlingController
  extend ActiveSupport::Concern

  included do
    unless Rails.application.config.consider_all_requests_local
      rescue_from ActionController::InvalidAuthenticityToken do
        respond_with_error :bad_request
      end

      rescue_from ActiveRecord::RecordNotFound,
                  ActionController::RoutingError do
        set_error_locale
        respond_with_error :not_found
      end

      rescue_from ActionController::UnknownFormat do
        set_error_locale
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
      format.jpeg do
        send_file "#{Rails.root}/app/assets/images/errors/hint.jpg",
                  disposition: :inline
      end
      format.all do
        head status
      end
    end
  end

  private

  def set_error_locale
    available_locales = I18n.available_locales.map(&:to_s)
    locale = params[:locale].to_s.presence
    if locale.nil? || !locale.in?(available_locales)
      locale = I18n.default_locale
    end
    I18n.locale = Globalize.locale = locale
  end
end
