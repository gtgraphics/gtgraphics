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
      attr_readonly :embeddable_type

      belongs_to :embeddable, polymorphic: true, autosave: true

      validates :embeddable, presence: true
      validates :embeddable_type, inclusion: { in: EMBEDDABLE_TYPES }, allow_blank: true

      # Destruction must be done through a callback, because "dependent: :destroy" leads to an infinite loop
      after_destroy :destroy_embeddable

      delegate :template, :template=, :template_id, :template_id=, to: :embeddable, allow_nil: true

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

    def embeddable_attributes=(attributes)
      raise 'invalid embeddable type' unless embeddable_class
      if attributes['id'].present?
        embeddable_id = attributes['id'].to_i
        self.embeddable = embeddable_class.find_by(id: embeddable_id) if self.embeddable_id != embeddable_id
      end
      build_embeddable if embeddable.nil?
      self.embeddable.attributes = attributes
    end

    def embeddable_class
      embeddable_type.in?(EMBEDDABLE_TYPES) ? embeddable_type.constantize : nil
    end

    def embeddable_class_was
      embeddable_type_was.try(:constantize)
    end

    def embeddable_changed?
      embeddable_type_changed? or embeddable_id_changed?
    end

    # Templates

    def available_templates
      template_class.try(:all) || Template.none
    end

    def check_template_support!
      raise Template::NotSupported.new(self) unless support_templates?
    end

    def support_templates?
      embeddable_class.try(:support_templates?) || false
    end

    def template_class
      embeddable.class.template_class if support_templates?
    end

    def template_path
      template.try(:view_path)
    end

    private
    def destroy_embeddable
      embeddable.destroy
    end
  end
end