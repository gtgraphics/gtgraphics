class Presenter
  attr_accessor :object, :template, :options
 
  def initialize(object, template, options = {})
    @object = object
    @template = template
    @options = options
  end
 
  def self.presents(name)
    define_method name do
      @object
    end
  end
 
  def inspect
    "#<#{self.class.name} object: #{object.inspect}>"
  end
 
  def method_missing(method_name, *args, &block)
    if template and template.respond_to?(method_name)
      template.send(method_name, *args, &block)
    else
      super
    end
  end
 
  def respond_to_missing?(method_name, include_private = false)
    (template and template.respond_to?(method_name)) or super
  end
end