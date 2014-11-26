class CollectionFilter
  include ActiveModel::Model
  include Virtus.model

  FILTERED_ATTR_CONDITION = :present?.to_proc
  FILTERED_ATTR_CONDITION_BY_TYPE = {
    'Boolean' => lambda { |value| !value.nil? }
  }.freeze

  class_attribute :filter_attribute_set, instance_accessor: false
  self.filter_attribute_set = ActiveSupport::HashWithIndifferentAccess.new

  def initialize(relation, *args)
    @relation = relation
    super(*args)
    yield(self) if block_given?
  end

  def self.filters(name, *args, &block)
    options = args.extract_options!
    type = args.first || String

    default_cond = FILTERED_ATTR_CONDITION_BY_TYPE.fetch(type.to_s, FILTERED_ATTR_CONDITION)
    default_filter = block || lambda do |relation, name, value|
      relation.where(name => value)
    end
    options = options.reverse_merge(with: default_filter, if: default_cond)
    
    self.filter_attribute_set = filter_attribute_set.merge(name => options)
    attribute name, type, options
  end

  def attributes
    super.select { |name, value| value_present?(name, value) }
  end

  def result
    attributes.inject(@relation) do |relation, (name, value)|
      options = self.class.filter_attribute_set[name]
      return relation if options.nil?
      filter_proc = options[:with]
      if filter_proc.arity == 3
        try_call(filter_proc, relation, name, value)
      else
        try_call(filter_proc, relation, value)
      end
    end
  end

  private
  def value_present?(name, value)
    options = self.class.filter_attribute_set[name]
    return false if options.nil?
    try_call(options.fetch(:if, true), value) &&
    !try_call(options.fetch(:unless, false), value)
  end

  def try_call(evaluable, *args)
    if evaluable.is_a?(Symbol)
      self.send(evaluable)
    elsif evaluable.respond_to?(:to_proc)
      self.instance_exec(*args, &evaluable)
    else
      evaluable
    end
  end
end