# composed_of :meta_keywords, class_name: 'TokenCollection', mapping: %w(meta_keywords to_s), converter: :new

class TokenCollection
  DEFAULTS = {
    separator: ',',
    sort: false,
    unique: false
  }

  attr_reader :tokens, :options

  def initialize(tokens, options = {})
    @options = options.reverse_merge(DEFAULTS)
    if tokens.is_a?(String)
      @tokens = tokens.split(@options[:separator])
    else
      @tokens = tokens.to_a
    end
    @tokens.sort! if @options[:sort]
    @tokens.uniq! if @options[:unique]
  end

  def inspect
    "#<#{self.class.name} tokens: #{tokens.inspect}, options: #{options.inspect}>"
  end

  def to_a
    @tokens
  end

  def to_s
    @tokens.join(options[:separator])
  end
end