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
    def handles(name, options = {})
      class_name = options.fetch(:class_name) { name.to_s.classify }.to_s
      class_eval <<-RUBY
        def model_name
          ActiveModel::Name.new(self, nil, '#{class_name}')
        end
      RUBY
      embeds_one name, class_name: class_name
    end

    def execute(attributes = {}, &block)
      new(attributes, &block).tap(&:execute)
    end
 
    def execute!(attributes = {}, &block)
      new(attributes, &block).tap(&:execute!)
    end
  end
 
  def execute
    execute!
  rescue ActivityInvalid
    false
  end
 
  def execute!
    raise ActivityInvalid.new(self) unless valid?
    run_callbacks :execute do
      perform
      true
    end
  end
 
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