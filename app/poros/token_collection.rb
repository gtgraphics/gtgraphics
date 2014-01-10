class TokenCollection
  TOKEN_SEPARATOR = ','

  attr_reader :tokens

  def initialize(tokens)
    if tokens.is_a?(String)
      @tokens = tokens.split(TOKEN_SEPARATOR)
    else
      @tokens = tokens.to_a
    end
  end

  def self.parse(tokens)
    new(tokens)
  end

  def inspect
    "#<#{self.class.name} tokens: #{tokens.inspect}>"
  end

  def to_a
    tokens
  end

  def to_s
    tokens.join(TOKEN_SEPARATOR)
  end
end