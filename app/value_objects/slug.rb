# composed_of :slug, mapping: %w(slug to_s), allow_nil: true, converter: :new

class Slug < String
  DEFAULT_SEPARATOR = '-'

  attr_reader :options

  def initialize(str, options = {})
    @options = options.reverse_merge(separator: DEFAULT_SEPARATOR)
    super(str.parameterize(@options[:separator]))
  end

  def inspect
    "#<#{self.class.name} #{super}>"
  end

  def succ
    if self =~ Regexp.new(Regexp.escape(options[:separator]) + '[0-9]+\z')
      str = super
    else
      str = "#{self}-2"
    end
    self.class.new(str, options)
  end

  alias_method :next, :succ
end