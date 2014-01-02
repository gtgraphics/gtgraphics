module PageEmbeddable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_page_embeddable(options = {})
      raise 'acts_as_page_embeddable cannot be defined twice on the same model' if @embeddable_options

      options = options.reverse_merge(convertible: true, creatable: true, multiple: false, destroy_with_page: false).freeze

      if options[:multiple]
        has_many :pages, as: :embeddable, dependent: :destroy
        has_many :regions, -> { readonly }, through: :pages

        #after_save do
        #  pages.each(&:touch)
        #end
      else
        has_one :page, as: :embeddable, dependent: :destroy
        delegate :slug, :path, :published?, :hidden?, to: :page, allow_nil: true
        has_many :regions, -> { readonly }, through: :page

        #after_save do
        #  page.touch
        #end
      end

      @page_embeddable_options = options
    end

    def bound_to_page?
      page_embeddable_options[:destroy_with_page]
    end

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