module Translatable
  extend ActiveSupport::Concern

  included do 
    extend Macro
    extend Migration
    include Scopes

    cattr_accessor(:translated_column_names, instance_accessor: false) { [] }

    has_many :translations, class_name: "::#{self.name}::Translation", autosave: true, dependent: :destroy

    after_save :save_translation, if: :observe_translation?

    alias_method_chain :attributes, :translation
    alias_method_chain :changed, :translation
    alias_method_chain :changed?, :translation
    alias_method_chain :changes, :translation
    alias_method_chain :previous_changes, :translation
    alias_method_chain :reload, :translation
    alias_method_chain :valid?, :translation
  end

  module ClassMethods
    def translation_table_name
      reflect_on_association(:translations).klass.table_name
    end

    def translated_columns_hash
      reflect_on_association(:translations).klass.columns_hash.slice(translated_column_names)
    end

    def translated_columns
      translated_columns_hash.values
    end
  end

  module Macro
    def translates(*column_names)
      column_names = column_names.map(&:to_s)
      column_names.each do |column_name|
        self.class_eval %Q(
          def #{column_name}
            read_translated_attribute(:#{column_name})
          end

          def #{column_name}=(value)
            write_translated_attribute(:#{column_name}, value)
          end

          def #{column_name}_change
            translation.#{column_name}_change
          end

          def #{column_name}_changed?
            translation.#{column_name}_changed?
          end

          def #{column_name}_was
            translation.#{column_name}_was
          end

          def #{column_name}_will_change!
            translation.#{column_name}_will_change!
          end

          def #{column_name}_translation(locale)
            #{column_name}_translations[locale]
          end

          def #{column_name}_translations
            Hash[*translations.collect do |translation|
              [translation.locale, translation.#{column_name}]
            end.flatten].with_indifferent_access.merge(translation.locale => translation.#{column_name}).freeze
          end
        )
      end
      self.translated_column_names += column_names
    end
  end

  module Migration
    def create_translation_table(options = {})
      connection.create_table(translation_table_name, options.slice(:force, :options)) do |table|
        table.belongs_to self.model_name.singular.to_sym, index: true, null: false
        table.string :locale, index: true, null: false, limit: 2
        yield(table)
      end
      clear_schema_cache!
    end

    def change_translation_table(&block)
      connection.change_table(translation_table_name, &block)
      clear_schema_cache!
    end

    def drop_translation_table
      connection.drop_table(translation_table_name)
      clear_schema_cache!
    end

    private
    def clear_schema_cache!
      connection.schema_cache.clear! if connection.respond_to?(:schema_cache)
      self::Translation.reset_column_information
      self.reset_column_information
    end
  end

  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :with_translation, -> { with_translation_for(I18n.locale) }
      scope :with_translations, -> { joins(:translations) }
    end

    module ClassMethods
      def with_translation_for(*locales)
        joins(:translations).where(reflect_on_association(:translations).klass.table_name.to_sym => { locale: locales.flatten }).uniq.includes(:translations)
      end
    end
  end

  def attributes_with_translation
    attributes_without_translation.merge(translated_attributes)      
  end

  def build_translation(*args)
    attributes = args.extract_options!
    locale = args.first.to_s.presence || I18n.locale
    translation = translations.build(attributes.reverse_merge(locale: locale))
    translation_cache[locale] = translation
    translation
  end

  def build_translations_for(*locales)
    attributes = locales.extract_options!
    locales.flatten.each do |locale|
      if translates?(locale)
        translation = translation_for(locale)
        translation.attributes = attributes if attributes
        translation
      else
        build_translation(attributes.merge(locale: locale))
      end
    end
  end

  def changed_with_translation
    changed_without_translation + translation.changed
  end

  def changed_with_translation?
    changed_without_translation? or translation.changed?
  end

  def changes_with_translation
    changes_without_translation.merge(translation.changes.slice(*self.class.translated_column_names))
  end

  def clear_translation_cache!
    @translation_cache.clear
  end

  def previous_changes_with_translation
    previous_changes_without_translation.merge(translation.previous_changes)
  end

  def read_translated_attribute(column_name, locale = I18n.locale)
    if I18n.respond_to? :fallbacks
      translation_for(locale).read_attribute(column_name) || begin
        fallbacks = Array(I18n.fallbacks[locale.to_sym] || I18n.default_locale)
        fallback = fallbacks.detect { |fallback| translation_for(fallback).nil? }
        translation_for(fallback) if fallback
      end
    else
      translation_for(locale).read_attribute(column_name)
    end
  end

  def reload_with_translation
    clear_translation_cache!
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

  def translates?(locale)
    !translation_for(locale).nil?
  end

  def translation
    translation_for(I18n.locale)
  end

  def translation_cache
    @translation_cache ||= {}
  end

  def translation_for(locale)
    translation_cache[locale.to_s] ||= if translations.loaded?
      translations.detect { |translation| translation.locale == locale.to_s }
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

  def write_translated_attribute(column_name, value, locale = I18n.locale)
    build_translation(locale) if translation.nil?
    translation.write_attribute(column_name, value)
  end

  private
  def observe_translation?
    translation and (translation.new_record? or translation.changed?)
  end

  def save_translation
    translation.save
  end
end