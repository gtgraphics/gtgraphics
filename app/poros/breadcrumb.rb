class Breadcrumb
  attr_reader :breadcrumbs, :caption, :destination
  private :breadcrumbs

  def initialize(breadcrumbs, caption, destination)
    @breadcrumbs = breadcrumbs
    @caption = caption.to_s
    @destination = destination
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