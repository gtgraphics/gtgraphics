module PageEmbeddable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_page_embeddable(options = {})
      raise 'acts_as_page_embeddable cannot be defined twice on the same model' if @embeddable_options

      options = options.reverse_merge(convertible: true, creatable: true).freeze
      @page_embeddable_options = options

      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    included do
      has_one :page, as: :embeddable, dependent: :destroy
      has_many :regions, -> { readonly }, through: :page

      delegate :slug, :path, :published?, :hidden?, to: :page, allow_nil: true
    end

    module ClassMethods
      def convertible?
        page_embeddable_options[:convertible]
      end

      def creatable?
        page_embeddable_options[:creatable]
      end

      def page_embeddable_options
        @page_embeddable_options ||= {}
      end
    end
  end
end