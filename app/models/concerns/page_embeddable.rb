module PageEmbeddable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_page_embeddable(options = {})
      raise 'acts_as_page_embeddable cannot be defined twice on the same model' if @embeddable_options

      options = options.reverse_merge(multiple: false, destroy_with_page: false).freeze

      if options[:multiple]
        has_many :pages, as: :embeddable, dependent: :destroy
        has_many :regions, -> { readonly }, through: :pages
      else
        has_one :page, as: :embeddable, dependent: :destroy
        delegate :slug, :path, :published?, :hidden?, to: :page, allow_nil: true
        has_many :regions, -> { readonly }, through: :page
      end

      @page_embeddable_options = options
    end

    def bound_to_page?
      page_embeddable_options.fetch(:destroy_with_page, false)
    end

    def page_embeddable_options
      @page_embeddable_options ||= {}
    end
  end
end