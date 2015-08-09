# Provides an abstract interface for creating form objects
class Form
  include ActiveModel::Model
  include Virtus.model
  extend ActiveModel::Callbacks

  autoload :EmbedsOneExtension, 'form/embeds_one_extension'
  autoload :EmbedsManyExtension, 'form/embeds_many_extension'
  autoload :FormInvalid, 'form/form_invalid'

  include EmbedsOneExtension
  include EmbedsManyExtension

  define_model_callbacks :initialize, :validation, :submit
  class_attribute :handled_object_name, instance_accessor: false

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
      define_method "#{name}?" do
        public_send(name).present?
      end
    end

    alias_method_chain :attribute, :form

    def submit(attributes = {}, &block)
      new(attributes, &block).tap(&:submit)
    end

    def submit!(attributes = {}, &block)
      new(attributes, &block).tap(&:submit!)
    end

    def handles(name, options = {})
      class_name = options.fetch(:class_name) { name.to_s.classify }.to_s
      class_eval <<-RUBY
        def model_name
          ActiveModel::Name.new(self, nil, '#{class_name}')
        end
      RUBY
      embeds_one name, class_name: class_name
      self.handled_object_name = name
    end

    def delegate_attributes(*names)
      options = names.extract_options!.reverse_merge(
        to: handled_object_name, allow_nil: true
      )
      names.each do |name|
        delegate name, "#{name}=", "#{name}?", options
      end
    end

    alias_method :delegate_attribute, :delegate_attributes
  end

  def submit(options = {})
    submit!(options)
  rescue FormInvalid
    false
  end

  def submit!(options = {})
    unless perform_validations(options)
      fail FormInvalid.new(self),
           "Validation failed: #{errors.full_messages.join(', ')}"
    end
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
    return if options[:validate] == false
    valid?(options[:context])
  end
end
