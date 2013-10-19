##
# Provides a fix to prevent Globalize from creating a translation for
# the current locale when saving a record.

module BatchTranslatable
  extend ActiveSupport::Concern

  def translation
    @translation ||= (translation_for(::Globalize.locale, false) || self.class.translation_class.new(locale: ::Globalize.locale))
  end
end