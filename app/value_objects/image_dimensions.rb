class ImageDimensions
  include Comparable

  attr_reader :width, :height

  def initialize(width, height)
    @width = width || 0
    @height = height || 0
  end

  def self.parse(*args)
    case args.size
    when 1
      dimensions = args.first
      if dimensions.nil?
        nil
      elsif dimensions.respond_to?(:width) and dimensions.respond_to?(:height)
        new(dimensions.width.to_i, dimensions.height.to_i)
      elsif dimensions.is_a?(String)
        new(*dimensions.split('x'))
      elsif dimensions.is_a?(Array)
        new(*dimensions)
      elsif dimensions.is_a?(Rational)
        new(dimensions.numerator, dimensions.denominator)
      else
        raise ArgumentError, "#{dimensions.inspect} cannot be converted to #{self.name}"
      end
    when 2
      new(*args)
    else
      raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)"
    end
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

  def to_a
    [width, height]
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