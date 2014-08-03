module ConcreteTemplate
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_concrete_template(options = {})
      acts_as_concrete_template_for(self.model_name.element, options)
    end

    # acts_as_concrete_template :homepage, class_name: 'Page::Homepage', lookup_path: 'homepages/templates'
    def acts_as_concrete_template_for(page_type, options = {})
      class_name = options.fetch(:class_name) { "Page::#{page_type.to_s.classify}" }
      lookup_path = options.fetch(:lookup_path) { "#{class_name.pluralize.underscore}/templates" }

      self.template_lookup_path = lookup_path

      has_many :"#{page_type}_pages", class_name: class_name,
                                      foreign_key: :template_id,
                                      dependent: :restrict_with_error
      has_many :pages, through: :"#{page_type}_pages"

      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    included do
      acts_as_list

      default_scope -> { order(:position) }
    end

    module ClassMethods
      def default
        first
      end

      def default!
        first!
      end
    end

    def default?
      first?
    end

    def make_default
      move_to_top
    end
  end
end