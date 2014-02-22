class ImageDimensions
  include Comparable

  attr_reader :width, :height

  def initialize(width, height)
    @width = width || 0
    @height = height || 0
  end

  def <=>(other)
    pixels <=> other.to_i
  end

  def aspect_ratio
    to_r unless @width.zero? or @height.zero?
  end

  def inspect
    "#<#{self.class.name} width: #{width}, height: #{height}>"
  end

  def pixels
    width * height
  end

  def to_i
    pixels
  end

  def to_r
    Rational(width, height)
  end

  def to_s
    I18n.translate(:dimensions, width: width, height: height, aspect_ratio: aspect_ratio, pixels: pixels, default: super)
  end
end