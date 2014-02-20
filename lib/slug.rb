class Slug
  DEFAULT_SEPARATOR = '-'

  attr_reader :options

  def initialize(str, options = {})
    @options = options.reverse_merge!(separator: DEFAULT_SEPARATOR)
    @str = str.parameterize(@options[:separator])
  end

  def next
    dup.next!
  end

  def next!
    if @str =~ Regexp.new(Regexp.escape(options[:separator]) + '[0-9]+\z')
      @str = @str.next
    else
      @str = "#{@str}-2"
    end
    self
  end

  def inspect
    "#<#{self.class.name} #{@str}>"
  end

  alias_method :succ, :next

  def to_s
    @str
  end
end