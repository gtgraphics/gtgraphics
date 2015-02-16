module ResourceBreadcrumbController
  extend ActiveSupport::Concern

  RECORD_CAPTION_METHODS = %i(name title to_s).freeze

  module ClassMethods
    def breadcrumbs_for_resource(*args)
      options = args.extract_options!

      record_caption_methods = Array(options.fetch(:record_caption) { RECORD_CAPTION_METHODS })

      breadcrumbs(options.slice(:only, :except, :if, :unless)) do |b, controller|
        parent_resource = args.first.present? && try_call(options[:parent]) != false

        controller_namespace = options.fetch(:namespace) do
          controller.class.name.deconstantize.split('::').map(&:underscore)
        end
        controller_namespace = try_call(controller_namespace)
        if controller_namespace == false
          controller_namespace = []
        else
          controller_namespace = Array(controller_namespace).flatten.map(&:to_sym)
        end

        # Determine collection and element names
        resource_class =
          case args.first
          when NilClass then controller.controller_name.classify.constantize
          when Class then args.first
          when Symbol, String then args.first.to_s.classify.constantize
          else fail ArgumentError, 'resource element and collection name ' \
                                   'could not be determined by reflection'
          end
        element_name = resource_class.model_name.element.to_sym
        collection_name = resource_class.model_name.collection.to_sym

        @parent_breadcrumb_records ||= []

        if parent_resource
          record = load_record(element_name, options)
          if record
            if !singular_string?(args.first.to_s) and try_call(options[:include_collection]) != false
              b.append(resource_class.model_name.human(count: 2), controller_namespace + [collection_name])
            end
            record_caption = load_caption(record)
            if try_call(options[:include_element]) != false
              b.append(record_caption, controller_namespace + @parent_breadcrumb_records + [record])
            end
            @parent_breadcrumb_records << record
          end
        else
          # Resource is primary resource in controller
          if try_call(options[:include_collection]) != false
            b.append(resource_class.model_name.human(count: 2), controller_namespace + @parent_breadcrumb_records + [collection_name])
          end

          if controller.action_name.in? %w(show edit update)
            record = load_record(element_name, options)
            if record
              record_caption = load_caption(record)
              if try_call(options[:include_element]) != false
                b.append(record_caption, controller_namespace + @parent_breadcrumb_records + [record])
              end
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

  private

  def load_caption(record)
    RECORD_CAPTION_METHODS.collect { |method| record.try(method) }.compact.first
  end

  def load_record(element_name, options)
    record = instance_variable_get("@#{element_name}")
    if options[:allow_nil] != true && record.nil?
      fail "@#{element_name} has not been set in " \
           "#{self.class.name.deconstantize.underscore}/" \
           "#{controller_name}##{action_name}"
    end
    record
  end

  def singular_string?(str)
    str.pluralize != str && str.singularize == str
  end

  def try_call(proc_or_symbol_or_object)
    if proc_or_symbol_or_object.is_a? Symbol
      method(proc_or_symbol_or_object).call
    elsif proc_or_symbol_or_object.respond_to? :call
      instance_eval(&proc_or_symbol_or_object)
    else
      proc_or_symbol_or_object
    end
  end
end
