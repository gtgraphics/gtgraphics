class Page < ActiveRecord::Base
  module Templatable
    extend ActiveSupport::Concern

    included do
      has_many :regions, class_name: 'Page::Region', dependent: :destroy,
                         inverse_of: :page

      validates :template_id, presence: true, if: :support_templates?

      delegate :name, to: :template, prefix: true, allow_nil: true

      class << self
        alias_method :with_template, :with_templates
      end
    end

    module ClassMethods
      def with_templates(*template_files)
        join_sources = []
        template_join_conditions = []

        embeddable_classes.select(&:support_templates?).each do |klass|
          # Join Embeddables table
          embd_join = arel_table.join(klass.arel_table, Arel::Nodes::OuterJoin)
          join_sources << embd_join.on(
            arel_table[:embeddable_id].eq(klass.arel_table[:id]).and(
              arel_table[:embeddable_type].eq(klass.name)
            )
          ).join_sources

          # Build join condition for embeddable table
          template_join_conditions << klass.arel_table[:template_id].eq(
            Template.arel_table[:id]
          )
        end

        # Join templates table
        join_sources << arel_table.join(Template.arel_table).on(
          template_join_conditions.reduce(:or)
        ).join_sources

        # Build scope
        names = template_files.many? ? template_files : template_files.first
        joins(join_sources).where(templates: { file_name: names })
      end
    end

    def available_templates
      template_class.try(:all) || Template.none
    end

    def check_template_support!
      fail Template::NotSupported.new(self) unless support_templates?
    end

    def support_templates?
      embeddable_class.try(:support_templates?) || false
    end

    def template_class
      embeddable.class.template_class if support_templates?
    end

    %w(template template_id).each do |method_name|
      class_eval <<-RUBY
        def #{method_name}
          check_template_support!
          embeddable.try(:#{method_name})
        end

        def #{method_name}=(value)
          check_template_support!
          embeddable.public_send(:#{method_name}=, value)
        end
      RUBY
    end
  end
end
