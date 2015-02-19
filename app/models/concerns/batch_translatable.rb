module BatchTranslatable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_batch_translatable(options = {})
      accepts_nested_attributes_for :translations,
                                    options.reverse_merge(allow_destroy: true)
      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    included do
      validate :verify_translations_count
    end

    ##
    # Provides a fix to prevent Globalize from creating a translation for
    # the current locale when saving a record.

    def translation
      @translation ||= (translation_for(::Globalize.locale, false) ||
        self.class.translation_class.new(locale: ::Globalize.locale))
    end

    private

    def verify_translations_count
      return unless translations.size.zero?
      errors.add(:translations, :greater_than, count: 1)
    end
  end
end
