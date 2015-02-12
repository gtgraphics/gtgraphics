class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception unless Rails.env.development?

  before_action :set_current_user
  before_action :set_locale

  include BreadcrumbController
  include ErrorHandlingController
  include FlashableController
  include MaintainableController
  include RouteHelper

  protected

  def default_url_options(_options = nil)
    { locale: I18n.locale }
  end

  def live?
    Rails.env.in? %w(production staging)
  end

  def force_no_ssl_redirect
    return true unless request.ssl?
    url_options = { protocol: 'http://', host: request.host,
                    path: request.fullpath }
    insecure_url = url_for(url_options)
    flash.keep if respond_to?(:flash)
    redirect_to insecure_url, status: :moved_permanently
    false
  end

  private

  def set_current_user
    User.current = current_user
  end

  def set_locale
    available_locales = I18n.available_locales.map(&:to_s)
    locale = params[:locale]
    if locale && locale.in?(available_locales)
      Globalize.locale = I18n.locale = locale.to_sym
    else
      # if user is logged in his preferred locale will be used
      # if none of the above is set the locale will be determined through the
      # HTTP Accept Language header from the browser
      locale = current_user.try(:preferred_locale)
      locale ||= http_accept_language.compatible_language_from(
        I18n.available_locales)
      redirect_to params.merge(locale: locale.to_s, id: params[:id].presence)
    end
  end
end
