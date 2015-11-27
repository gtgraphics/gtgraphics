class RandomString
  attr_reader :alphabet, :length

  class << self
    def default_alphabet
      @default_alphabet ||=
        [('A'..'Z'), ('a'..'z'), ('0'..'9')].map(&:to_a).flatten
    end

    def default_length
      @default_length ||= 8
    end

    attr_writer :default_alphabet, :default_length
  end

  def self.generate(options = {})
    new(options).to_s
  end

  def initialize(options = {})
    @length = options.fetch(:length) { self.class.default_length }
    @alphabet = options.fetch(:alphabet) { self.class.default_alphabet }
  end

  def to_s
    @length.times.collect { alphabet.sample }.join
  end
end
