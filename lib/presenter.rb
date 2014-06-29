class Presenter
  def initialize(template, *args)
    @template = template
    @options = args.extract_options!
    @object = args.first
  end

  attr_reader :object, :options, :template
  alias_method :h, :template

  delegate :present, to: :h

  protected :h, :present, :object, :options, :template
 
  class << self
    def presents(name)
      class_eval <<-RUBY
        def #{name}
          @object
        end
        protected :#{name}
      RUBY
    end
  end

  def inspect
    if @object.nil?
      "#<#{self.class.name}>"
    else
      "#<#{self.class.name} object: #{@object.inspect}>"
    end
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