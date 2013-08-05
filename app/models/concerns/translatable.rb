module Translatable
  extend ActiveSupport::Concern

  included do 
    include Macro
    include Migrations

    cattr_accessor(:translated_columns, instance_accessor: false) { [] }
    cattr_accessor(:translated_column_names, instance_accessor: false) { [] }
    cattr_accessor(:translated_columns_hash, instance_accessor: false) { {} }

    has_many :translations, class_name: "#{self.name}::Translation", autosave: true, dependent: :destroy
    #has_one :translation, -> { where(locale: I18n.locale) }, class_name: "#{self.name}::Translation"

    scope :with_translation_for, ->(locale) { joins(:translations).where(reflect_on_association(:translations).klass.table_name.to_sym => { locale: locale }) }

    with_options if: :observe_translation? do |translatable|
      #translatable.validate :validate_translation
      translatable.after_save :save_translation
    end

    alias_method_chain :attributes, :translation
    alias_method_chain :attributes=, :translation
    alias_method_chain :changed?, :translation
    alias_method_chain :changes, :translation
    alias_method_chain :reload, :translation
    alias_method_chain :valid?, :translation
  end

  module Macro
    extend ActiveSupport::Concern

    module ClassMethods
      def translates(*column_names)
        translation_columns = reflect_on_association(:translations).klass.columns_hash
        column_names = column_names.map(&:to_s)
        column_names.each do |column_name|
          column = translation_columns.fetch(column_name)
          self.translated_columns << column
          self.translated_columns_hash[column_name] = column

          self.class_eval %Q(
            def #{column_name}
              translation.#{column_name}
            end

            def #{column_name}=(value)
              build_translation if translation.nil?
              translation.#{column_name} = value
            end

            def #{column_name}_changed?
              translation.#{column_name}_changed?
            end

            def #{column_name}_translation(locale)
              #{column_name}_translations[locale]
            end

            def #{column_name}_translations
              Hash[*translations.collect do |translation|
                [translation.locale, translation.#{column_name}]
              end.flatten].with_indifferent_access.merge(translation.locale => translation.#{column_name}).freeze
            end

            def #{column_name}_translated?(locale = I18n.locale)
              !translation_for(locale).nil?
            end
          )
        end
        self.translated_column_names += column_names
      end
    end
  end

  module Migrations
    extend ActiveSupport::Concern

    module ClassMethods
      def create_translation_table!(columns)
        raise NotImplemented
      end

      def drop_translation_table!(columns)
        raise NotImplemented
      end
    end
  end

  def attributes_with_translation
    attributes_without_translation.merge(translated_attributes)      
  end

  def attributes_with_translation=(attributes)
    raise attributes.inspect
    attributes_without_translation(attributes)
  end

  def build_translation(*args)
    attributes = args.extract_options!
    locale = args.first || I18n.locale
    translations.build(attributes.reverse_merge(locale: locale))
  end

  def changed_with_translation?
    changed_without_translation? or translation.changed?
  end

  def changes_with_translation
    changes_without_translation.merge(translation.changes.slice(*self.class.translated_column_names))
  end

  def reload_with_translation
    if translation
      reload_without_translation and translation.reload
    else
      reload_without_translation
    end
  end

  def translated_attributes
    translated_attributes_for(I18n.locale)
  end

  def translated_attributes_for(locale)
    if translation = translation_for(locale)
      translation.attributes.slice(*self.class.translated_column_names)
    else
      Hash[*self.class.translated_column_names.map { |column| [column, nil] }.flatten]
    end
  end

  def translation
    translation_for(I18n.locale)
  end

  def translation_for(locale)
    @loaded_translations ||= {}
    @loaded_translations[locale.to_s] ||= if translations.loaded?
      translations.detect { |t| t.locale == locale.to_s }
    else
      translations.find_by_locale(locale.to_s)
    end
  end

  def translations_hash
    translations.group_by(&:locale).with_indifferent_access
  end

  def valid_with_translation?(context = nil)
    if translation
      valid = valid_without_translation?(context) && translation.valid?(context)
      # copy validation errors from translation
      translation.errors.messages.slice(*self.class.translated_column_names.map(&:to_sym)).each do |column_name, error_messages|
        errors.set(column_name, error_messages)
      end
      valid
    else
      valid_without_translation?(context)
    end
  end

  private
  def observe_translation?
    translation and (translation.new_record? or translation.changed?)
  end

  def save_translation
    translation.save
  end

  #def validate_translation
  #  translation.valid?
  #end
end