class ApplicationController < ActionController::Base
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

  def production?
    Rails.env.production?
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
      locale = http_accept_language
               .compatible_language_from(I18n.available_locales)
      locale = I18n.default_locale if locale.blank?

      binding.pry

      redirect_to params.to_h.with_indifferent_access.merge(
        locale: locale.to_s, id: params[:id].presence)
    end
  end
end
