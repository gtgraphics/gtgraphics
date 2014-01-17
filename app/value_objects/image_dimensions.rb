class ImageDimensions
  attr_reader :width, :height

  def initialize(width, height)
    @width = width || 0
    @height = height || 0
  end

  def aspect_ratio
    Rational(width, height) unless @width.zero? or @height.zero?
  end

  def inspect
    "#<#{self.class.name} width: #{width}, height: #{height}>"
  end

  def pixels
    width * height
  end

  def to_s
    I18n.translate(:dimensions, width: width, height: height, aspect_ratio: aspect_ratio, pixels: pixels, default: super)
  end
end