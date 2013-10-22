module BatchTranslatable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_batch_translated
      include InstanceMethods

      validate :validate_translations_count
    end
  end

  module InstanceMethods
    ##
    # Provides a fix to prevent Globalize from creating a translation for
    # the current locale when saving a record.

    def translation
      @translation ||= (translation_for(::Globalize.locale, false) || self.class.translation_class.new(locale: ::Globalize.locale))
    end

    private
    def validate_translations_count
      errors.add(:translations, :greater_than, count: 1) if translations.size.zero?
    end
  end
end