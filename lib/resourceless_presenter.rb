class ResourcelessPresenter
  attr_reader :object, :options, :template
  alias_method :h, :template
  protected :h, :object, :options, :template

  def initialize(template, options = {})
    @template = template
    @options = options
  end

  def inspect
    "#<#{self.class.name}>"
  end
 
  def method_missing(method_name, *args, &block)
    if object.respond_to?(method_name)
      object.send(method_name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    (object and object.respond_to?(method_name, include_private)) or super
  end
end