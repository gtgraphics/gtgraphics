# composed_of :slug, mapping: %w(slug to_s), allow_nil: true, converter: :new

class Slug < String
  DEFAULT_SEPARATOR = '-'

  attr_reader :separator

  def initialize(str, options = {})
    @separator = options.fetch(:separator, DEFAULT_SEPARATOR)
    super(str.parameterize(@separator))
  end

  def inspect
    "#<#{self.class.name} #{super}>"
  end

  def succ
    if self =~ Regexp.new(Regexp.escape(@separator) + '[0-9]+\z')
      str = super
    else
      str = "#{self}#{@separator}2"
    end
    self.class.new(str, separator: @separator)
  end

  alias_method :next, :succ
end
