class Form
  include ActiveModel::Model
  include Virtus.model
  extend ActiveModel::Callbacks

  include Form::EmbedsOneExtension
  include Form::EmbedsManyExtension
 
  define_model_callbacks :initialize, :validation, :execute

  def initialize(*)
    run_callbacks :initialize do
      form = super
      yield(form) if block_given?
    end
  end
 
  class << self
    def attribute_with_form(name, *args)
      attribute_without_form(name, *args)

      unless method_defined?("#{name}?")
        class_eval <<-RUBY
          def #{name}?
            #{name}.present?
          end
        RUBY
      end
    end

    alias_method_chain :attribute, :form

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
  rescue FormInvalid
    false
  end
 
  def execute!
    raise FormInvalid.new(self) unless valid?
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
    raise NotImplementedError, "#{self.class.name}#perform must be overridden to execute this form"
  end
end