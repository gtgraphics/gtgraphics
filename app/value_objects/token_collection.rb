class TokenCollection
  DEFAULTS = {
    sort: false,
    unique: false
  }
  TOKEN_SEPARATOR = ','

  attr_reader :tokens

  def initialize(tokens, options = {})
    @options = options.reverse_merge(DEFAULTS)
    if tokens.is_a?(String)
      @tokens = tokens.split(TOKEN_SEPARATOR)
    else
      @tokens = tokens.to_a
    end
    @tokens.sort! if options[:sort]
    @tokens.uniq! if options[:unique]
  end

  def self.parse(tokens, options = {})
    new(tokens, options)
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