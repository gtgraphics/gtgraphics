# Provides an abstract interface for creating form objects
class Form
  include ActiveModel::Model
  include Virtus.model
  extend ActiveModel::Callbacks

  include Form::EmbedsOneExtension
  include Form::EmbedsManyExtension

  define_model_callbacks :initialize, :validation, :submit

  def initialize(*)
    run_callbacks :initialize do
      form = super
      yield(form) if block_given?
    end
  end

  class << self
    def attribute_with_form(name, *args)
      attribute_without_form(name, *args)
      return if method_defined?("#{name}?")
      class_eval <<-RUBY
        def #{name}?
          #{name}.present?
        end
      RUBY
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

    def submit(attributes = {}, &block)
      new(attributes, &block).tap(&:submit)
    end

    def submit!(attributes = {}, &block)
      new(attributes, &block).tap(&:submit!)
    end
  end

  def submit(options = {})
    submit!(options)
  rescue FormInvalid
    false
  end

  def submit!(options = {})
    fail FormInvalid.new(self) unless perform_validations(options)
    run_callbacks :submit do
      perform
      true
    end
  end

  def inspect
    if self.class.attribute_set.any?
      attributes_str = ' ' + self.class.attribute_set.map(&:name).map do |key|
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
    fail NotImplementedError, "#{self.class.name}#perform must be overridden " \
                              'to submit this form'
  end

  private

  def perform_validations(options = {})
    options[:validate] == false || valid?(options[:context])
  end
end
