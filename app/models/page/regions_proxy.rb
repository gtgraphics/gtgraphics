class Page < ActiveRecord::Base
  class RegionsProxy
    include Enumerable

    def initialize(page)
      @page = page
      raise Template::RegionDefinition::NotSupported.new(template) unless page.supports_regions?
      @regions_hash = regions.inject(ActiveSupport::HashWithIndifferentAccess.new) do |regions_hash, region|
        regions_hash.merge!(region.definition.label => region.body) unless region.marked_for_destruction?
        regions_hash
      end
    end

    def [](label)
      fetch(label, nil)
    end

    def []=(label, body)
      store(label, body)
    end

    def defined_regions
      @regions_hash.keys
    end

    def delete(label, &block)
      region_definition = region_definition_by_label(label)
      region = region_by_definition(region_definition, false)
      if region
        region_translation = region_translation_by_locale(region, I18n.locale, false)
        if region_translation and region.translations.reject(&:marked_for_destruction?).any? { |translation| translation != region_translation }
          # Only remove translation if other translations are available
          region_translation.mark_for_destruction
        else
          # Remove entire region if no other translations than the current one are available
          region.mark_for_destruction 
        end
      end
      @regions_hash.delete(label, &block)
    end

    delegate :each, :empty?, :inspect, :to_h, :to_hash, :to_s, to: :@regions_hash

    def fetch(label, default = nil, &block)
      region_definition = region_definition_by_label(label)
      @regions_hash.fetch(region_definition.label, default, &block)
    end

    def regions
      @regions_hash.values
    end

    def store(label, body)
      region_definition = region_definition_by_label(label)
      region = region_by_definition(region_definition, true)
      region_translation = region_translation_by_locale(region, I18n.locale, true)
      region_translation.body = body
      @regions_hash[label] = body
    end

    private
    attr_reader :page, :region_definitions_hash
    delegate :template, :regions, to: :page
    delegate :region_definitions, to: :template

    def region_definition_by_label(label)
      region_definition = region_definitions.detect { |definition| definition.label == label.to_s }
      raise Template::RegionDefinition::NotFound.new(label, template) if region_definition.nil?
      region_definition
    end

    def region_by_definition(region_definition, buildable = false)
      region = regions.detect { |region| region.definition == region_definition }
      region ||= regions.build(definition: region_definition) if buildable
      region
    end

    def region_translation_by_locale(region, locale, buildable = false)
      region_translation = region.translations.reject(&:marked_for_destruction?).detect { |translation| translation.locale == locale }
      region_translation ||= region.translations.build(locale: locale) if buildable
      region_translation
    end
  end
end