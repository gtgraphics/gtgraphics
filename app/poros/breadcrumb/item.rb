class Breadcrumb::Item
  extend ActiveModel::Naming

  attr_reader :collection, :caption, :destination, :path, :url
  private :collection

  def initialize(collection, caption, destination)
    raise ArgumentError, 'no breadcrumb collection specified' if collection.nil?
    #raise ArgumentError, 'caption is blank' if caption.blank?
    raise ArgumentError, 'no destination specified' if destination.nil?

    @collection = collection
    @caption = caption
    @destination = destination
    if @destination.is_a? String
      @path = @url = @destination
    else
      @path = collection.controller.url_for(destination)
      @url = collection.controller.url_for(destination)
    end
  end

  def index
    collection.index(self)
  end

  def first?
    index.zero?
  end

  def last?
    index == collection.length - 1
  end

  def inspect
    "#<#{self.class.name} caption: #{caption.inspect}, destination: #{destination.inspect}>"
  end

  def to_s
    caption
  end
end