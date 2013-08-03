module BreadcrumbedController
  RECORD_CAPTION_METHODS = %i(name title to_s).freeze

  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumbs
  end

  module ClassMethods
    protected
    def breadcrumb(caption, destination, options = {})
      before_action(options) do |controller|
        controller.breadcrumbs.append(caption, destination)
      end
    end

    def breadcrumbs(options = {}, &block)
      raise ArgumentError, 'no block given' unless block_given?
      before_action(options) do |controller|
        controller.instance_exec(breadcrumbs, controller, &block)
      end
    end

    def breadcrumbs_for_resource(*args)
      options = args.extract_options!

      record_caption_methods = Array(options.fetch(:record_caption) { RECORD_CAPTION_METHODS })
      parent_resource = args.first.present? && options[:parent] != false

      breadcrumbs(options.slice(:only, :except)) do |b, controller|
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

        @parent_breadcrumb_records ||= []

        if parent_resource
          record = load_record(element_name, options)
          if record
            unless singular_string?(args.first.to_s)
              b.append(resource_class.model_name.human(count: 2), controller_namespace + [collection_name]) if options[:include_collection] != false
            end
            record_caption = load_caption(record)
            b.append(record_caption, controller_namespace + @parent_breadcrumb_records + [record]) if options[:include_element] != false
            @parent_breadcrumb_records << record
          end
        else
          # Resource is primary resource in controller
          b.append(resource_class.model_name.human(count: 2), controller_namespace + @parent_breadcrumb_records + [collection_name]) if options[:include_collection] != false

          if controller.action_name.in? %w(show edit update)
            record = load_record(element_name, options)
            if record
              record_caption = load_caption(record)
              b.append(record_caption, controller_namespace + @parent_breadcrumb_records + [record]) if options[:include_element] != false
            end
          end

          if controller.action_name.in? %w(new create)
            b.append(I18n.translate('breadcrumbs.new', model: resource_class.model_name.human), [:new, controller_namespace, element_name].flatten(1))
          end

          if controller.action_name.in? %w(edit update)
            b.append(I18n.translate('breadcrumbs.edit', model: resource_class.model_name.human), [:edit, controller_namespace, record].flatten(1))
          end
        end
      end
    end
  end

  protected
  def breadcrumbs
    @breadcrumbs ||= BreadcrumbCollection.new(self)
  end

  private
  def load_caption(record)
    RECORD_CAPTION_METHODS.collect { |method| record.try(method) }.compact.first
  end

  def load_record(element_name, options)
    record = instance_variable_get("@#{element_name}")
    raise "@#{element_name} has not been set in #{self.class.name.deconstantize.underscore}/#{controller_name}##{action_name}" if options[:allow_nil] != true and record.nil?
    record
  end

  def singular_string?(str)
    str.pluralize != str and str.singularize == str
  end
end