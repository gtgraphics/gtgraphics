class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_current_user
  before_action :set_locale

  include AuthenticatableController
  include BreadcrumbController
  include FlashableController
  include MaintainableController
  include RouteHelper

  unless Rails.env.development?
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end
  rescue_from Authenticatable::AccessDenied, with: :force_authentication

  private
  def default_url_options(options = {})
    { locale: I18n.locale }
  end

  def force_authentication
    respond_to do |format|
      format.html do
        flash[:after_sign_in_path] = request.path
        redirect_to :admin_sign_in
      end
      format.all { head :unauthorized }
    end
  end

  def render_404
    respond_to do |format|
      format.html { render 'public/404', layout: false, status: :not_found }
      format.all { head :not_found }
    end
  end

  def set_locale
    available_locales = I18n.available_locales.map(&:to_s)
    if locale = params[:locale] and locale.in?(available_locales)
      I18n.locale = session[:locale] = locale.to_sym
    else
      # if user is logged in his preferred locale will be used
      # if session includes a locale that locale will be used
      # if none of the above is set the locale will be determined through the HTTP Accept Language header from the browser
      locale = (current_user.try(:preferred_locale) || session[:locale] || http_accept_language.compatible_language_from(I18n.available_locales)).to_s
      redirect_to params.merge(locale: locale, id: params[:id].presence)
    end
  end
end
