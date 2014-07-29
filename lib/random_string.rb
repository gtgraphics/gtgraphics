class RandomString
  CHARS = [
    ('A'..'Z'),
    ('a'..'z'),
    ('0'..'9'),
    ['#', '!', '?', '=', '/', '+', '@', '$']
  ]

  attr_reader :length, :chars

  def initialize(length, options = {})
    @length = length
    @chars = Array(options.fetch(:chars, CHARS)).map do |element|
      element.is_a?(Range) ? element.to_a : element
    end.flatten
  end

  def self.generate(length, options = {})
    new(length, options).generate
  end

  def generate
    length = @length.is_a?(Range) ? rand(@length) : @length
    length.times.collect { @chars.sample }.shuffle.join
  end
  alias_method :to_s, :generate
end