class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  private
  def render_404
    respond_to do |format|
      format.html { render 'public/404', status: :not_found }
      format.all { head :not_found }
    end
  end

  def set_locale
    if params[:locale] and I18n.available_locales.map(&:to_s).include?(params[:locale])
      I18n.locale = params[:locale].to_sym
    else
      redirect_to locale: http_accept_language.compatible_language_from(I18n.available_locales)
    end
  end
end
