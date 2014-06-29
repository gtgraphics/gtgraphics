module Translatable
  extend ActiveSupport::Concern

  module ClassMethods
    def with_translations_for_current_locale
      includes(:translations).with_locales(Globalize.fallbacks).references(:translations)
    end
  end
end