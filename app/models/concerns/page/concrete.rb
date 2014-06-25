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
        config_accessor(:template_class_name) { "Template::#{self.name.demodulize}" }
        config_accessor(:routing_resource_name) { self.model_name.element.to_sym }

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
        self.table_name = "#{self.model_name.element}_pages"

        has_one :page, as: :embeddable, dependent: :destroy
        delegate :slug, :path, to: :page, allow_nil: true

        if support_templates?
          belongs_to :template, class_name: template_class_name 
          has_many :regions, through: :page

          validates :template_id, presence: true

          after_update :migrate_regions, if: :template_id_changed?
        end
      end

      module ClassMethods
        def support_templates?
          !!template_class_name
        end

        def template_class
          template_class_name.try(:constantize)
        end
      end

      private
      def migrate_regions
        
      end
    end
  end
end