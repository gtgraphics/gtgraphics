class Activity
  if ActiveModel::VERSION::STRING =~ /^3/
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    include ActiveModel::Validations
    include ActiveModel::Conversion
    include ActiveModel::MassAssignmentSecurity
  else
    include ActiveModel::Model
  end
  include Virtus.model
  extend ActiveModel::Callbacks
 
  class ActivityInvalid < StandardError
    attr_reader :activity
 
    def initialize(activity)
      @activity = activity
      super("Validation failed: #{@activity.errors.full_messages.join(', ')}") if @activity
    end
  end
 
  define_model_callbacks :initialize, :validation, :execute

  def initialize(*)
    run_callbacks :initialize do
      super
    end
  end
 
  class << self
    def execute(attributes = {})
      new(attributes).tap(&:execute)
    end
    alias_method :create, :execute
 
    def execute!(attributes = {})
      new(attributes).tap(&:execute!)
    end
    alias_method :create!, :execute!
 
    protected
    def embeds_one(association_name, options = {})
      options.reverse_merge!(class_name: association_name.to_s.classify)
      klass = options[:class_name]
 
      class_eval %{
        def #{association_name}=(object)
          @#{association_name} = object
          @#{association_name}_id = object.send(#{klass}.primary_key)
        end
 
        attribute :#{association_name}_id, Integer

        def #{association_name}
          @#{association_name} ||= (#{klass}.where(#{klass}.primary_key => #{association_name}_id).first if #{association_name}_id.present?)
        end
 
        def #{association_name}_id=(id)
          @#{association_name} = #{klass}.where(#{klass}.primary_key => id).first
          super
        end
      }
    end
 
    def embeds_many(association_name)
      singular_association_name = association_name.to_s.singularize
      options.reverse_merge!(class_name: association_name.to_s.classify)
      klass = options[:class_name]
 
      class_eval %{
        def #{association_name}
          @#{association_name} ||= (#{klass}.where(#{klass}.primary_key => #{singular_association_name}_ids) if #{singular_association_name}_ids.present?)
        end
 
        def #{association_name}=(objects)
          @#{association_name} = objects
          @#{singular_association_name}_ids = objects.collect { |object| object.send(#{klass}.primary_key) }
        end
 
        attribute :#{singular_association_name}_ids, Array[Integer]
 
        def #{singular_association_name}_ids=(ids)
          @#{association_name} = #{klass}.where(#{klass}.primary_key => ids)
          super
        end
      }
    end
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

  if Rails.version =~ /^3/
    def persisted?
      false
    end
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