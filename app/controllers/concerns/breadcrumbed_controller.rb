module BreadcrumbedController
  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumbs
  end

  module ClassMethods
    protected
    def breadcrumb(caption, destination, options = {})
      before_action(options) do |controller|
        controller.breadcrumbs.add(caption, destination)
      end
    end

    def breadcrumbs(&block)
      raise ArgumentError, 'no block given' unless block_given?
      before_action do |controller|
        controller.instance_exec(breadcrumbs, controller, &block)
      end
    end

    def breadcrumbs_for_resource(*args)
      options = args.extract_options!

      record_caption_methods = Array(options.fetch(:record_caption) { [:name, :title, :to_s] })
      parent_resource = args.first.present? && options[:parent] != false

      breadcrumbs do |b, controller|
        controller_namespace = options.fetch(:namespace) do
          controller.class.name.deconstantize.split('::').map(&:underscore)
        end
        if controller_namespace == false
          controller_namespace = []
        else
          controller_namespace = Array(controller_namespace).map(&:to_sym)
        end

        # Determine collection and element names
        resource_class = case args.first
        when NilClass then controller.controller_name.classify.constantize
        when Class then args.first
        when Symbol, String then args.first.to_s.classify.constantize
        else raise ArgumentError, 'resource element and collection name could not be determined by reflection'
        end
        element_name = resource_class.model_name.element.to_sym
        collection_name = resource_class.model_name.collection.to_sym

        if parent_resource
          # Resource is parent resource in controller
          raise NotImplementedError, 'parent resources are not yet supported'
        else
          # Resource is primary resource in controller
          b.add(resource_class.model_name.human(count: 2), controller_namespace + [collection_name])

          if controller.action_name.in? %w(show edit update)
            record = controller.instance_variable_get("@#{element_name}")
            record_caption = record_caption_methods.collect { |method| record.try(method) }.compact.first
            b.add record_caption, controller_namespace + [record]
          end

          if controller.action_name.in? %w(new create)
            b.add(I18n.translate('breadcrumbs.new', model: resource_class.model_name.human), [:new, controller_namespace, element_name].flatten(1))
          end

          if controller.action_name.in? %w(edit update)
            b.add(I18n.translate('breadcrumbs.edit', model: resource_class.model_name.human), [:edit, controller_namespace, record].flatten(1))
          end
        end
      end
    end
  end

  protected
  def breadcrumbs
    @breadcrumbs ||= BreadcrumbCollection.new(self)
  end
end