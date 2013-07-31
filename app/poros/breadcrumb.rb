class Breadcrumb
  attr_reader :breadcrumbs, :caption, :destination
  private :breadcrumbs

  def initialize(breadcrumbs, caption, destination)
    raise ArgumentError, 'no caption specified' if caption.blank?
    raise ArgumentError, 'no destination specified' if destination.nil?
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

  def path
    if destination.is_a? String
      destination
    else
      breadcrumbs.controller_context.polymorphic_path(destination)
    end
  end

  def to_s
    caption
  end

  def url
    if destination.is_a? String
      destination
    else
      breadcrumbs.controller_context.polymorphic_url(destination)
    end
  end
end