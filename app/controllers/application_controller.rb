class ApplicationController < ActionController::Base
  include Router::ControllerAdapter
  include BreadcrumbController
  include FlashableController
  include MaintainableController
  include ImageRouteExtensibleController

  protect_from_forgery with: :exception

  before_action :set_current_user
  before_action :set_locale

  helper_method :safe_params

  protected

  def live?
    Rails.env.in? %w(production staging)
  end

  def production?
    Rails.env.production?
  end

  private

  class_attribute :enforce_redirect_to_localized_url, :detect_locale_from_headers
  self.enforce_redirect_to_localized_url = true
  self.detect_locale_from_headers = true

  def localized_request_url(locale)
    url_for(params.to_h.with_indifferent_access
            .merge(locale: locale, id: params[:id].presence))
  end

  def set_locale
    locale = params[:locale].try(:to_s)
    available_locales = I18n.available_locales.map(&:to_s)

    if locale.blank? || available_locales.exclude?(locale)
      if detect_locale_from_headers?
        locale = http_accept_language.compatible_language_from(available_locales)
      end
      locale ||= I18n.default_locale
      if enforce_redirect_to_localized_url?
        redirect_to localized_request_url(locale)
        return
      end
    end

    Globalize.locale = I18n.locale = locale.to_sym
  end

  def safe_params
    request.query_parameters.merge(request.path_parameters)
  end

  private

  def set_current_user
    User.current = current_user
  end
end
