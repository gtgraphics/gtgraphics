class Page < ActiveRecord::Base
  module Abstract
    extend ActiveSupport::Concern

    EMBEDDABLE_TYPES = %w(
      Page::Content
      Page::ContactForm
      Page::Homepage
      Page::Image
      Page::Project
      Page::Redirection
    ).freeze

    included do
      attr_readonly :embeddable_type, :embeddable_id

      belongs_to :embeddable, polymorphic: true, autosave: true

      validates :embeddable, presence: true
      validates :embeddable_type, inclusion: { in: EMBEDDABLE_TYPES }, allow_blank: true

      # Destruction must be done through a callback, because "dependent: :destroy" leads to an infinite loop
      after_destroy :destroy_embeddable

      accepts_nested_attributes_for :embeddable

      EMBEDDABLE_TYPES.each do |embeddable_type|
        sanitized_type = embeddable_type.demodulize.underscore

        scope sanitized_type.pluralize, -> { where(embeddable_type: embeddable_type) }
        scope "except_#{sanitized_type.pluralize}", -> { where.not(embeddable_type: embeddable_type) }

        class_eval <<-RUBY
          def #{sanitized_type}?
            embeddable_type == '#{embeddable_type}'
          end
        RUBY
      end
    end

    module ClassMethods
      def creatable_embeddable_classes
        embeddable_classes.select(&:creatable?).freeze
      end

      def embedding(*types)
        types = Array(types).flatten.map { |type| "Page::#{type.to_s.classify}" }
        where(embeddable_type: types.many? ? types : types.first)
      end

      def embeddable_classes
        @@embeddable_classes ||= embeddable_types.map(&:constantize).freeze
      end

      def embeddable_types
        EMBEDDABLE_TYPES
      end
    end

    def build_embeddable(attributes = {})
      raise 'invalid embeddable type' unless embeddable_class
      self.embeddable = embeddable_class.new(attributes)
    end

    def children_with_embedded(*types)
      children.embedding(*types).includes(:embeddable)
    end

    def embeddable_class
      embeddable_type.in?(EMBEDDABLE_TYPES) ? embeddable_type.constantize : nil
    end

    private
    def destroy_embeddable
      embeddable.try :destroy
    end
  end
end