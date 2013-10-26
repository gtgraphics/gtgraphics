class Admin::GalleriesController < Admin::ApplicationController
  respond_to :html

  def translation_fields
    translated_locale = params.fetch(:translated_locale)
    @gallery = Gallery.new
    @gallery.translations.build(locale: translated_locale)
    respond_to do |format|
      format.html do
        if translated_locale.in?(I18n.available_locales.map(&:to_s))
          render layout: false 
        else
          head :not_found
        end
      end
    end
  end
end