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

  def default_url_options(options = nil)
    { locale: I18n.locale }
  end

  def live?
    Rails.env.in? %w(production staging)
  end

  private

  def set_current_user
    User.current = current_user
  end

  def set_locale
    available_locales = I18n.available_locales.map(&:to_s)
    if locale = params[:locale] and locale.in?(available_locales)
      Globalize.locale = I18n.locale = locale.to_sym
    else
      # if user is logged in his preferred locale will be used
      # if none of the above is set the locale will be determined through the HTTP Accept Language header from the browser
      locale = (current_user.try(:preferred_locale) || http_accept_language.compatible_language_from(I18n.available_locales)).to_s
      redirect_to params.merge(locale: locale, id: params[:id].presence)
    end
  end
end
