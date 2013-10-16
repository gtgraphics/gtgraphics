class Breadcrumb::Collection
  include Enumerable

  attr_reader :controller

  def initialize(controller)
    @collection = []
    @controller = controller
  end

  def append(caption, destination)
    add_with_method(:push, caption, destination)
  end

  alias_method :add, :append

  def inspect
    substr = " " + map { |item| "\"#{item.caption}\"=>\"#{item.path}\"" }.join(', ')
    "#<#{self.class.name}#{substr.strip}>"
  end

  def prepend(caption, destination)
    add_with_method(:unshift, caption, destination)
  end

  delegate :clear, :count, :each, :index, :length, to: :@collection

  private
  def add_with_method(method, caption, destination)
    @collection.send(method, Breadcrumb::Item.new(self, caption, destination))

    #options.assert_valid_keys(:only, :except)
    #breadcrumb_addable = options[:only] && controller.action_name.in?(Array(options[:only]).map(&:to_s))
    #breadcrumb_addable ||= options[:except] && !controller.action_name.in?(Array(options[:except]).map(&:to_s))
    #breadcrumb_addable ||= options[:only].nil? && options[:except].nil?
    #@collection.send(method, Breadcrumb::Item.new(self, caption, destination)) if breadcrumb_addable
  end
end