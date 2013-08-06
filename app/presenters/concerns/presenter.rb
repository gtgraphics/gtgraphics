module Presenter
  extend ActiveSupport::Concern
 
  included do
    attr_accessor :attributes
    class << self
      protected :new
    end
  end
 
  module ClassMethods
    def presenter_name
      self.name.gsub(/Presenter\Z/, '').underscore
    end
 
    def render(attributes = {})
      new.tap do |presenter|
        presenter.attributes = attributes.freeze
        attributes.each do |key, value|
          presenter.instance_variable_set(:"@#{key}", value)
        end
      end.to_html
    end
  end
 
  def inspect
    "#<#{self.class.name} attributes: #{attributes.inspect}>"
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
 
  def to_html
    raise NotImplementedError, "you must override #to_html in #{self.class.name}"
  end
 
  protected
  def controller_context
    RequestStore.store[:controller_context]
  end
 
  def template
    controller_context.try(:view_context)
  end
end