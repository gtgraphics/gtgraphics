class Authenticatable::PasswordGenerator
  CHARS = [
    ('A'..'Z').to_a,
    ('a'..'z').to_a,
    ('0'..'9').to_a,
    ['#', '!', '?', '=', '/', '+', '@', '$']
  ].flatten.freeze
  DEFAULT_LENGTH = 10..12

  attr_reader :length, :chars

  def initialize(*args)
    options = args.extract_options!
    @length = args.first || DEFAULT_LENGTH
    @chars = options.fetch(:chars, CHARS)
  end

  def self.generate(*args)
    new(*args).generate
  end

  def generate
    length = @length.is_a?(Range) ? rand(@length) : @length
    length.times.collect { CHARS.sample }.shuffle.join
  end
  alias_method :to_s, :generate
end