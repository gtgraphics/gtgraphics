class Image::Dimensions
  attr_reader :width, :height

  def initialize(width, height)
    @width = width
    @height = height
  end

  def to_a
    [width, height]
  end

  def to_h
    { width: width, height: height }
  end

  def to_s
    "#{width} × #{height}"
  end
end