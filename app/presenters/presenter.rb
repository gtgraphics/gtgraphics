class Presenter
  attr_reader :object, :template, :options
 
  def initialize(object, template, options = {})
    @object = object
    @template = template
    @options = options.reverse_merge(self.class.defaults || {})
  end

  class << self
    attr_accessor :defaults

    def presents(name, defaults = {})
      define_method name do
        @object
      end
      self.defaults = defaults
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