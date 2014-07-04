class Activity
  include ActiveModel::Model
  include Virtus.model
  extend ActiveModel::Callbacks

  include Activity::EmbedsOneExtension
  include Activity::EmbedsManyExtension
 
  define_model_callbacks :initialize, :validation, :execute

  def initialize(*)
    run_callbacks :initialize do
      activity = super
      yield(activity) if block_given?
    end
  end
 
  class << self
    def execute(attributes = {}, &block)
      new(attributes, &block).tap(&:execute)
    end
    alias_method :create, :execute
 
    def execute!(attributes = {}, &block)
      new(attributes, &block).tap(&:execute!)
    end
    alias_method :create!, :execute!
  end
 
  def execute
    execute!
  rescue ActivityInvalid
    false
  end
  alias_method :save, :execute
 
  def execute!
    raise ActivityInvalid.new(self) unless valid?
    run_callbacks :execute do
      perform
      true
    end
  end
  alias_method :save!, :execute!
 
  def inspect
    if self.class.attribute_set.any?
      attributes_str = " " + self.class.attribute_set.map(&:name).map do |key|
        "#{key}: #{attributes[key].inspect}"
      end.join(', ')
    end
    "#<#{self.class.name}#{attributes_str}>"
  end
 
  def valid?(*)
    run_callbacks :validation do
      super
    end
  end
 
  def to_s
    inspect
  end
 
  protected
  def perform
    raise NotImplementedError, "#{self.class.name}#perform must be overridden to execute this activity"
  end
end