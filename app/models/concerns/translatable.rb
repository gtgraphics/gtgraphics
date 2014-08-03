module Translatable
  extend ActiveSupport::Concern

  module ClassMethods
    def order_by_translated(*columns)
      columns = columns.flat_map { |column| translation_class.arel_table[:column] }
      order(*columns)
    end

    def with_translations_for_current_locale
      includes(:translations).where(translation_class.table_name => { locale: [*Globalize.fallbacks, nil] })
    end
  end
end