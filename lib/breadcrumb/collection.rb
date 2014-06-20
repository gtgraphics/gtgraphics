class Breadcrumb::Collection
  include Enumerable

  attr_reader :controller

  def initialize(controller)
    @items = []
    @controller = controller
  end

  def append(caption, destination = nil)
    add_with_method(:push, caption, destination)
  end

  alias_method :add, :append

  def inspect
    "#<#{self.class.name} count: #{@items.count}>"
  end

  def prepend(caption, destination)
    add_with_method(:unshift, caption, destination)
  end

  delegate :clear, :count, :each, :first, :index, :last, :length, :[], to: :@items

  private
  def add_with_method(method, caption, destination)
    @items.send(method, Breadcrumb::Item.new(self, caption, destination))
  end
end