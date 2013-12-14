class Activity
  include ActiveModel::Model
  include Virtus.model
  extend ActiveModel::Callbacks

  class ActivityInvalid < Exception
    attr_reader :activity

    def initialize(activity)
      @activity = activity
      super("Validation failed: #{@activity.errors.full_messages.join(', ')}") if @activity
    end
  end

  define_model_callbacks :validation, :execution

  class << self
    def execute(attributes = {})
      new(attributes).tap(&:execute)
    end
    alias_method :create, :execute

    def execute!(attributes = {})
      new(attributes).tap(&:execute!)
    end
    alias_method :create!, :execute!
  end

  def execute
    return false unless valid?
    executed = true
    run_callbacks :execution do
      begin
        perform
      rescue Exception => e
        executed = false
      end
    end
    executed
  end
  alias_method :save, :execute

  def execute!
    raise ActivityInvalid.new(self) unless valid?
    run_callbacks :execution do
      perform
    end
    true
  end
  alias_method :save!, :execute!

  def inspect
    attributes_str = " " + attributes.map { |key, value| "#{key}: #{value.inspect}" }.join(', ') if attributes.any?
    "#<#{self.class.name}#{attributes_str}>"
  end

  def perform
    raise NotImplementedError, "#{self.class.name}#perform must be overridden to execute this activity"
  end

  def valid?(*)
    run_callbacks :validation do
      super
    end
  end
end