class BreadcrumbCollection < Array
  CAPTION_LOOKUP_ORDER = [:name, :title, :to_s]

  attr_reader :controller_context

  def initialize(controller_context)
    super()
    @controller_context = controller_context
  end

  def add(caption, destination, options = {})
    options.assert_valid_keys(:only, :except)

    breadcrumb_addable = options[:only] && controller_context.action_name.to_sym.in?(Array(options[:only]).map(&:to_sym))
    breadcrumb_addable ||= options[:except] && !controller_context.action_name.to_sym.in?(Array(options[:except]).map(&:to_sym))
    breadcrumb_addable ||= options[:only].nil? && options[:except].nil?

    self << Breadcrumb.new(self, caption, destination) if breadcrumb_addable
  end

  def inspect
    substr = map { |item| "\"#{item.caption}\"=>\"#{item.path}\"" }.join(', ')
    "#<#{self.class.name} #{substr}>"
  end
end