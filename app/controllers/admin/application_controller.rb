class Admin::ApplicationController < ApplicationController
  skip_maintenance_check

  force_ssl if: :production?

  before_action :require_login
  before_action :set_translation_locale

  reset_breadcrumbs

  protected

  def default_url_options(options = nil)
    translated_locale = Globalize.locale != I18n.locale ? Globalize.locale : nil
    super.merge(translations: translated_locale)
  end

  def not_authenticated
    respond_to do |format|
      format.html do
        redirect_to :admin_login,
                    alert: translate('helpers.flash.user.not_authenticated')
      end
      format.any { head :unauthorized }
    end
  end

  private

  def set_translation_locale
    available_locales = I18n.available_locales.map(&:to_s)
    locale = params[:translations]
    if locale && locale.in?(available_locales)
      Globalize.locale = locale
    else
      Globalize.locale = I18n.locale
    end
  end
end
