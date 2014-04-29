class Presenter
  attr_reader :template, :local_assigns
 
  class_attribute :defaults
  self.defaults = ActiveSupport::HashWithIndifferentAccess.new(defaults)

  def initialize(template, local_assigns = {})
    @template = template
    @local_assigns = local_assigns.with_indifferent_access.reverse_merge(defaults)
  end

  class << self
    def default(defaults)
      self.defaults.merge!(defaults)
    end

    def reset_defaults
      defaults.clear
    end
  end
 
  def inspect
    local_assigns_str = " " + @local_assigns.map { |key, value| "#{key}: #{value}" }.join(', ')
    "#<#{self.class.name}#{local_assigns_str.strip}>"
  end
 
  def method_missing(method_name, *args, &block)
    if template.respond_to?(method_name)
      template.send(method_name, *args, &block)
    elsif @local_assigns.key?(method_name)
      @local_assigns[method_name]
    else
      super
    end
  end
 
  def render
    raise NotImplemented
  end

  def respond_to_missing?(method_name, include_private = false)
    (template and template.respond_to?(method_name, include_private)) or super
  end
end