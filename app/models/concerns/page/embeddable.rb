class Page < ActiveRecord::Base
  module Embeddable
    extend ActiveSupport::Concern

    TITLE_CANDIDATES = %w(title name)

    mattr_accessor :list
    self.list = []

    module ClassMethods
      def acts_as_page_embeddable(options = {})
        class_attribute :embeddable_options, instance_accessor: false
        self.embeddable_options = options.reverse_merge(
          convertible: true,
          creatable: true,
          resource_name: self.model_name.element.to_sym,
          template_class: nil
        ).freeze
        include Extensions
        Page::Embeddable.list << self
      end
    end

    module Extensions
      extend ActiveSupport::Concern

      included do
        self.table_name = "#{self.model_name.element}_pages"

        belongs_to :template, class_name: template_type if supports_template?
        has_one :page, as: :embeddable, dependent: :destroy
        has_many :regions, through: :page if supports_regions?

        delegate :slug, :path, to: :page, allow_nil: true

        validates :template_id, presence: true if supports_template?
      end

      module ClassMethods
        def convertible?
          embeddable_options[:convertible]
        end

        def creatable?
          embeddable_options[:creatable]
        end

        def resource_name
          embeddable_options[:resource_name]
        end

        def supports_regions?
          supports_template?
        end

        def supports_template?
          template_type.present?
        end

        def template_class
          template_type.try(:constantize)
        end

        def template_type
          embeddable_options[:template_class].try(:to_s)
        end
      end
    end

    def to_param
      path
    end
  end
end