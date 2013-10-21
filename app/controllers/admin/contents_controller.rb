class Admin::ContentsController < Admin::ApplicationController
  def translation_fields
    translated_locale = params.fetch(:translated_locale)
    @content = Content.new
    @content.translations.build(locale: translated_locale)
    @page = Page.new(embeddable: @content)
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