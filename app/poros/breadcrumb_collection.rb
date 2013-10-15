class BreadcrumbCollection < Array
  attr_reader :controller_context

  def initialize(controller_context)
    super()
    @controller_context = controller_context
  end

  def append(caption, destination, options = {})
    add_with_method(:push, caption, destination, options)
  end

  alias_method :add, :append

  def inspect
    substr = " " + map { |item| "\"#{item.caption}\"=>\"#{item.path}\"" }.join(', ')
    "#<#{self.class.name}#{substr.strip}>"
  end

  def prepend(caption, destination, options = {})
    add_with_method(:unshift, caption, destination, options)
  end

  private
  def add_with_method(method, caption, destination, options)
    options.assert_valid_keys(:only, :except)

    breadcrumb_addable = options[:only] && controller_context.action_name.to_sym.in?(Array(options[:only]).map(&:to_sym))
    breadcrumb_addable ||= options[:except] && !controller_context.action_name.to_sym.in?(Array(options[:except]).map(&:to_sym))
    breadcrumb_addable ||= options[:only].nil? && options[:except].nil?

    send(method, Breadcrumb.new(self, caption, destination)) if breadcrumb_addable
  end
end