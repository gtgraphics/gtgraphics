class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_current_user
  before_action :set_locale

  include BreadcrumbController
  include ErrorHandlingController
  include FlashableController
  include MaintainableController
  include ImageRouteExtensibleController

  protected

  def live?
    Rails.env.in? %w(production staging)
  end

  def production?
    Rails.env.production?
  end

  protected

  def localized_request_url(locale)
    url_for(params.to_h.with_indifferent_access
            .merge(locale: locale, id: params[:id].presence))
  end

  private

  def set_current_user
    User.current = current_user
  end

  def set_locale
    locale = params[:locale].try(:to_s)
    available_locales = I18n.available_locales.map(&:to_s)

    if locale.present? && locale.in?(available_locales)
      Globalize.locale = I18n.locale = locale.to_sym
    else
      locale = http_accept_language.compatible_language_from(available_locales)
      redirect_to localized_request_url(locale || I18n.default_locale)
    end
  end
end
