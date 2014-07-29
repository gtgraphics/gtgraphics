# composed_of :meta_keywords, class_name: 'TokenCollection', mapping: %w(meta_keywords to_s), converter: :new

class TokenCollection
  DEFAULTS = {
    separator: ',',
    sort: false,
    unique: false
  }

  include Enumerable

  attr_reader :tokens, :options
  delegate :each, :empty?, :any?, :[], to: :to_a

  def initialize(tokens, options = {})
    @options = options.reverse_merge(DEFAULTS)
    if tokens.is_a?(String)
      @tokens = tokens.split(@options[:separator])
    else
      @tokens = tokens.to_a
    end
    @tokens.sort! if @options[:sort]
    @tokens = @tokens.to_set if @options[:unique]
  end

  def +(other)
    self.class.new(@tokens + other.to_a, @options)
  end

  def -(other)
    self.class.new(@tokens - other.to_a, @options)
  end

  def inspect
    "#<#{self.class.name} tokens: #{tokens.inspect}, options: #{options.inspect}>"
  end

  def to_a
    @tokens.to_a
  end

  def to_s
    to_a.join(options[:separator])
  end
end