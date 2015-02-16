module Translatable
  extend ActiveSupport::Concern

  module ClassMethods
    def order_by_translated(*columns)
      columns = columns.flat_map do |column|
        translation_class.arel_table[column]
      end
      order(*columns)
    end

    def with_translations_for_current_locale
      eager_load(:translations).where(
        translation_class.table_name => { locale: Globalize.fallbacks }
      )
    end
  end
end
