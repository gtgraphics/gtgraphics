class Admin::ApplicationController < ApplicationController
  skip_maintenance_check

  before_action :require_login
  before_action :set_translation_locale

  reset_breadcrumbs
  # breadcrumbs do |b|
  #   b.append I18n.translate('breadcrumbs.home'), :admin_root
  # end

  protected
  def default_url_options(options = nil)
    super.merge(translations: Globalize.locale != I18n.locale ? Globalize.locale : nil)
  end

  def not_authenticated
    respond_to do |format|
      format.html { redirect_to :admin_login, alert: translate('helpers.flash.user.not_authenticated') }
      format.any { head :unauthorized }
    end
  end

  private
  def set_translation_locale
    available_locales = I18n.available_locales.map(&:to_s)
    if locale = params[:translations] and locale.in?(available_locales)
      Globalize.locale = locale
    else
      Globalize.locale = I18n.locale
    end
  end
end