##
# Provides a fix to prevent Globalize from creating a translation for
# the current locale when saving a record.

module BatchTranslatable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_batch_translated
      include InstanceMethods
    end
  end

  module InstanceMethods
    def translation
      @translation ||= (translation_for(::Globalize.locale, false) || self.class.translation_class.new(locale: ::Globalize.locale))
    end
  end
end