class Page < ActiveRecord::Base
  module Concrete
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_concrete_page(options = {}, &block)
        include ActiveSupport::Configurable

        config_accessor(:creatable) { true }
        class << self
          alias_method :creatable?, :creatable
        end
        config_accessor(:template_class_name) do
          "Template::#{name.demodulize}"
        end
        config_accessor(:routing_resource_name) do
          model_name.element.to_sym
        end

        # Configure using a block or the options
        if block_given?
          configure(&block)
        else
          options.each do |key, value|
            send("#{key}=", value)
          end
        end

        include Extensions
      end
    end

    module Extensions
      extend ActiveSupport::Concern

      included do
        include Randomizable
        
        self.table_name = "#{model_name.element}_pages"

        has_one :page, as: :embeddable, dependent: :destroy
        delegate :slug, :path, to: :page, allow_nil: true

        include TemplateExtensions if support_templates?
      end

      module ClassMethods
        def support_templates?
          template_class_name.present?
        end

        def template_class
          template_class_name.try(:constantize)
        end
      end
    end

    module TemplateExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :template, class_name: template_class_name
        has_many :regions, through: :page

        validates :template_id, presence: true

        after_update :migrate_regions, if: :template_id_changed?

        class << self
          alias_method :with_template, :with_templates
        end
      end

      module ClassMethods
        def with_templates(*template_files)
          return none unless support_templates?
          template_files = template_files.flatten.map(&:to_s)
          joins(:template).where(templates: { file_name:
            template_files.one? ? template_files.first : template_files
          }).readonly(false)
        end
      end

      private

      def migrate_regions
        prev_template = Template.find(template_id_was)

        labels = template.region_definitions.pluck(:label)
        prev_labels = prev_template.region_definitions.pluck(:label)

        # Destroy regions that have no corresponding region label in
        # the new template
        destroyable_labels = labels - prev_labels
        regions.labelled(destroyable_labels).destroy_all

        # Update the regions to point to the new region definitions
        retained_labels = labels & prev_labels
        regions = self.regions.labelled(retained_labels)
        template.region_definitions
          .where(label: retained_labels).each do |region_definition|
          region = regions.find { |r| r.label == region_definition.label }
          region.update_column(:definition_id, region_definition.id) if region
        end
      end
    end
  end
end