module PageEmbeddable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_page_embeddable(options = {})
      @page_type_options = options.reverse_merge(convertible: true, creatable: true, template_class: nil).freeze
      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    included do
      self.table_name = "#{self.model_name.element}_pages"

      belongs_to :template, class_name: template_type if supports_template?
      has_one :page, as: :embeddable, dependent: :destroy
      has_many :regions, as: :regionable, dependent: :destroy if supports_regions?

      delegate :slug, :path, to: :page, allow_nil: true

      validates :template_id, presence: true if supports_template?
    end

    module ClassMethods
      def convertible?
        @page_type_options[:convertible]
      end

      def creatable?
        @page_type_options[:creatable]
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
        @page_type_options[:template_class].try(:to_s)
      end
    end
  end
end