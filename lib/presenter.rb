class Presenter
  def initialize(template, *args)
    @_template = template
    @options = args.extract_options!
    @object = args.first
  end

  attr_reader :object, :options
  delegate :present, to: :h
  protected :present, :options
 
  class << self
    def presents(name)
      define_method name do
        self.object
      end
    end
  end

  def inspect
    if object.nil?
      "#<#{self.class.name}>"
    else
      "#<#{self.class.name} object: #{@object.inspect}>"
    end
  end

  def method_missing(method_name, *args, &block)
    if object and object.respond_to?(method_name, false)
      object.send(method_name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    (object && object.respond_to?(method_name, include_private)) || super
  end

  protected
  def template
    @_template
  end
  alias_method :h, :template
end
