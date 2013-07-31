class BreadcrumbCollection < Array
  CAPTION_LOOKUP_ORDER = [:name, :title, :to_s]

  attr_reader :controller_context, :default_options

  def initialize(controller_context, options = {})
    super()
    @controller_context = controller_context
    @default_options = options
  end

  def add(caption, destination, options = {})
    options.assert_valid_keys(:only, :except)

    breadcrumb_addable = options[:only] && controller_context.action_name.to_sym.in?(Array(options[:only]).map(&:to_sym))
    breadcrumb_addable ||= options[:except] && !controller_context.action_name.to_sym.in?(Array(options[:except]).map(&:to_sym))
    breadcrumb_addable ||= options[:only].nil? && options[:except].nil?

    self << Breadcrumb.new(self, caption, destination) if breadcrumb_addable
  end

  def collection(collection_name_or_class, options = {})
    options = options.reverse_merge(default_options)
    options.assert_valid_keys(:only, :except, :namespace)

    namespace = options.delete(:namespace)
    klass = case collection_name_or_class
    when Symbol, String
      collection_name_or_class.to_s.classify.constantize
    else
      collection_name_or_class
    end
    caption = klass.model_name.human(count: 2)
    add(caption, [namespace, klass.model_name.collection].flatten(1).compact, options)
  end

  def element(record_name_or_object_or_class, options = {})
    options = options.reverse_merge(default_options)
    options.assert_valid_keys(:only, :except, :namespace)

    namespace = options.delete(:namespace)
    object = case record_name_or_object_or_class
    when Symbol, String
      controller_context.instance_variable_get("@#{record_name_or_object_or_class}")
    when Class
      controller_context.instance_variable_get("@#{record_name_or_object_or_class.model_name.element}")
    else
      record_name_or_object_or_class
    end
    caption = CAPTION_LOOKUP_ORDER.collect { |method| object.try(method) }.compact.first
    add(caption, [namespace, object].flatten(1).compact, options)
  end

  def resource(resource_name, options = {})
    element_options = options.dup
    element_options[:only] = %i(show edit update) & Array(options[:only]).map(&:to_sym) if options[:only]

    collection(resource_name, options)
    element(resource_name, element_options)
  end

  def inspect
    substr = map { |item| "\"#{item.caption}\"=>\"#{item.path}\"" }.join(', ')
    "#<#{self.class.name} #{substr}>"
  end
end