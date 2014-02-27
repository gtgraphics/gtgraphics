module Regionable
  extend ActiveSupport::Concern

  included do
    has_many :regions, class_name: 'Page::Region', dependent: :destroy, autosave: true

    before_update :migrate_regions, if: :embeddable_type_changed?
  end

  def available_regions
    @available_regions ||= (template && template.region_definitions.pluck(:label)) || []
  end

  def fetch_region(label, options = {})
    options.reverse_merge!(locale: I18n.locale)
    if definition = template.region_definitions.find_by(label: label)
      regions.with_translations(options[:locale]).find_by(definition: definition)
    else
      raise Template::RegionDefinition::NotFound.new(label, template)
    end
  end

  def remove_region(label)
    if definition = template.region_definitions.find_by(label: label)
      if region = regions.detect { |region| !region.marked_for_destruction? and region.definition == definition }
        translations = region.translations.reject(&:marked_for_destruction?)
        region_translation = translations.detect { |translation| translation.locale == I18n.locale }
        if region_translation and translations.any? { |translation| translation != region_translation }
          # Only remove translation if other translations are available
          region_translation.mark_for_destruction
        else
          # Remove entire region if no other translations than the current one are available
          region.mark_for_destruction 
        end
        region
      end
    else
      raise Template::RegionDefinition::NotFound.new(label, template)
    end
  end

  def store_region(label, body, options = {})
    options.reverse_merge!(locale: I18n.locale)
    definition = template.region_definitions.find_by(label: label)
    if definition
      region = regions.detect { |region| !region.marked_for_destruction? and region.definition == definition }
      region ||= regions.build(definition: definition)
      region_translation = region.translations.detect do |translation|
        !translation.marked_for_destruction? and translation.locale == options[:locale]
      end
      region_translation ||= region.translations.build(locale: options[:locale])
      region_translation.body = body
    else
      raise Template::RegionDefinition::NotFound.new(label, template)
    end
  end

  def supports_regions?
    embeddable_class.try(:supports_regions?) || false
  end

  private
  def migrate_regions
    # If changing the embeddable type, migrates the regions to the defined regions on the new template
    if supports_regions?
      # TODO
      # self.regions = regions.slice(available_regions)
    else
      regions.destroy_all
    end
  end
end