# composed_of :meta_keywords, class_name: 'TokenCollection', mapping: %w(meta_keywords to_s), converter: :new

class TokenCollection
  DEFAULTS = {
    separator: ',',
    sort: false,
    unique: false,
    allow_blank: false
  }.freeze

  include Enumerable

  attr_reader :tokens

  def initialize(tokens, options = {})
    @options = options.reverse_merge(DEFAULTS)
    if tokens.respond_to?(:to_a)
      @tokens = tokens.to_a
    else
      @tokens = tokens.to_s.split(separator)
    end
    @tokens.delete_if(&:blank?) unless allow_blank?
    @tokens.sort! if sorted?
    @tokens = @tokens.to_set if unique?
  end

  def +(other)
    self.class.new(self.to_a + other.to_a, @options)
  end

  def -(other)
    self.class.new(self.to_a - other.to_a, @options)
  end

  def inspect
    "#<#{self.class.name} tokens: #{tokens.inspect}, options: #{@options.inspect}>"
  end


  # Conversion

  delegate :to_a, :count, :each, :empty?, :any?, to: :tokens
  delegate :[], to: :to_a

  def to_s
    to_a.join(separator)
  end


  # Inquiry Methods

  def separator
    @options[:separator]
  end

  def sorted?
    @options[:sort]
  end

  def unique?
    @options[:unique]
  end

  def allow_blank?
    @options[:allow_blank]
  end
end