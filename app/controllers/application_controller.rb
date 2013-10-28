class ApplicationController < ActionController::Base
  include BreadcrumbController
  include RouteHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  breadcrumb I18n.translate('breadcrumbs.home'), :root

  private
  def render_404
    respond_to do |format|
      format.html { render 'public/404', layout: false, status: :not_found }
      format.all { head :not_found }
    end
  end

  def default_url_options(options = {})
    { locale: I18n.locale }
  end

  def set_locale
    if locale = params[:locale] and I18n.available_locales.map(&:to_s).include?(locale)
      I18n.locale = session[:locale] = locale.to_sym
    else
      locale = session[:locale] || http_accept_language.compatible_language_from(I18n.available_locales)
      redirect_to request.query_parameters.deep_symbolize_keys.merge(locale: locale).merge(params.slice(:format))
    end
  end
end
