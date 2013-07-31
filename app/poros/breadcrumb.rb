class Breadcrumb
  attr_reader :breadcrumbs, :caption, :destination, :path, :url
  private :breadcrumbs

  def initialize(breadcrumbs, caption, destination)
    raise ArgumentError, 'no caption specified' if caption.blank?
    raise ArgumentError, 'no destination specified' if destination.nil?
    @breadcrumbs = breadcrumbs
    @caption = caption.to_s
    @destination = destination
    if @destination.is_a? String
      @path = @url = @destination
    else
      @path = breadcrumbs.controller_context.polymorphic_path(destination)
      @url = breadcrumbs.controller_context.polymorphic_url(destination)
    end
  end

  def index
    breadcrumbs.index(self)
  end

  def first?
    index.zero?
  end

  def last?
    index == breadcrumbs.length - 1
  end

  def inspect
    "#<#{self.class.name} caption: #{caption.inspect}, destination: #{destination.inspect}>"
  end

  def to_s
    caption
  end
end