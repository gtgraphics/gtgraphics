class TagCollection
  include Enumerable

  SEPARATOR = ','

  attr_reader :taggable, :list
  delegate :taggings, to: :taggable, allow_nil: true
  private :taggable, :taggings

  def initialize(taggable_or_list = nil)
    if taggable_or_list.nil?
      @list = SortedSet.new
    elsif taggable_or_list.is_a?(Taggable)
      @taggable = taggable_or_list
      @list = SortedSet.new(@taggable.tags.pluck(:label))
    elsif taggable_or_list.respond_to?(:to_a)
      @list = SortedSet.new(taggable_or_list.to_a)
    else
      fail ArgumentError, 'First argument must be a Taggable or respond to #to_a'
    end
  end

  def self.parse(*args)
    list = args.flatten.flat_map do |arg|
      if arg.respond_to?(:to_a)
        arg.to_a.map(&:to_s)
      else
        arg.to_s.split(SEPARATOR)
      end
    end
    new(list)
  end

  delegate :to_a, :each, :count, :length, :any?, :empty?, to: :list
  delegate :[], to: :to_a

  def to_s
    to_a.join(SEPARATOR)
  end

  def inspect
    "#<#{self.class.name} list: #{list.inspect}>"
  end

  def initialize_copy(source)
    super
    @list = @list.dup
  end


  # Manipulation

  # def +(other)
  #   self.dup.tap { |tags| tags.add(other) }
  # end

  # def -(other)
  #   self.dup.tap { |tags| tags.remove(other) }
  # end

  def add(*args)
    added_tags = extract_tags(*args)
    @list += added_tags
    add_raw(added_tags) if model_bound?
    self
  end

  alias_method :<<, :add

  def add!(*args)
    added_tags = extract_tags(*args)
    @list += added_tags
    Tag.transaction { add_raw!(added_tags) } if model_bound?
    self
  end

  def set(*args)
    defined_tags = extract_tags(*args)
    @list = SortedSet.new(defined_tags)

    if model_bound?
      # Build all tags that are in the list
      add_raw(defined_tags)

      # Remove all tags that are not in the list
      taggings.reject do |tagging|
        tagging.label.to_s.in?(defined_tags)
      end.each(&:mark_for_destruction)
    end

    self
  end

  def set!(*args)
    defined_tags = extract_tags(*args)
    @list = SortedSet.new(defined_tags)

    if model_bound?
      Tag.transaction do
        # Build all tags that are in the list
        add_raw!(defined_tags)
        
        # Remove all tags that are not in the list
        taggings.joins(:tag).where.not(tags: { label: defined_tags }).readonly(false).destroy_all
      end
    end

    self
  end

  def remove(*args)
    removed_tags = extract_tags(*args)
    @list -= removed_tags

    if model_bound?
      taggings.select do |tagging|
        tagging.label.to_s.in?(removed_tags)
      end.each(&:mark_for_destruction)
    end

    self
  end

  def remove!(*args)
    removed_tags = extract_tags(*args)
    @list -= removed_tags
    taggings.joins(:tag).where(tags: { label: removed_tags }).readonly(false).destroy_all if model_bound?
    self
  end

  def clear
    @list.clear
    taggings.each(&:mark_for_destruction) if model_bound?
    self
  end

  def clear!
    @list.clear
    taggings.destroy_all if model_bound?
    self
  end

  private
  def extract_tags(*args)
    self.class.parse(*args).to_a
  end

  def add_raw(labels)
    fail 'Impossible to do this in this context' unless model_bound?
    labels.each do |label|
      if taggings.reject(&:marked_for_destruction?).none? { |tagging| tagging.label == label.to_s }
        tag = Tag.find_or_initialize_by(label: label)
        taggings.build(tag: tag)
      end
    end
  end

  def add_raw!(added_tags)
    fail 'Impossible to do this in this context' unless model_bound?
    added_tags.each do |label|
      tag = Tag.find_or_create_by!(label: label)
      taggings.find_or_create_by!(tag: tag)
    end
  end

  def model_bound?
    !taggable.nil?
  end
end
