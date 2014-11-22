class TagCollection
  DEFAULTS = {
    separator: ','
  }.freeze

  include Enumerable

  attr_reader :taggable, :list
  delegate :taggings, to: :taggable
  private :taggable, :taggings

  def initialize(taggable, options = {})
    @taggable = taggable
    @options = options.reverse_merge(DEFAULTS)
    @list = SortedSet.new(@taggable.tags.pluck(:label))
  end

  delegate :to_a, :each, :count, :length, :any?, :empty?, to: :list

  def inspect
    "#<#{self.class.name} list: #{list.inspect}, options: #{@options.inspect}>"
  end

  def separator
    @options[:separator]
  end


  # Manipulation

  def add(*args)
    added_tags = extract_tokens(*args)
    @list += added_tags

    added_tags.each do |token|
      if taggings.reject(&:marked_for_destruction?).none? { |tagging| tagging.label == token.to_s }
        taggings.build(tag: Tag[token])
      end
    end
  end

  def add!(*args)
    added_tags = extract_tokens(*args)
    @list += added_tags

    add_raw!(added_tags)
  end

  alias_method :<<, :add!

  def set(*args)
    defined_tags = extract_tokens(*args)
    @list = SortedSet.new(defined_tags)

    # Build all tags that are in the list
    add_raw(defined_tags)

    # Remove all tags that are not in the list
    taggings.reject do |tagging|
      tagging.label.to_s.in?(defined_tags)
    end.each(&:mark_for_destruction)
  end

  def set!(*args)
    defined_tags = extract_tokens(*args)
    @list = SortedSet.new(defined_tags)

    Tag.transaction do
      # Build all tags that are in the list
      add_raw!(defined_tags)
      
      # Remove all tags that are not in the list
      taggings.joins(:tag).where.not(tags: { label: defined_tags }).readonly(false).destroy_all
    end
  end

  def remove(*args)
    removed_tags = extract_tokens(*args)
    @list -= removed_tags

    taggings.select do |tagging|
      tagging.label.to_s.in?(removed_tags)
    end.each(&:mark_for_destruction)
  end

  def remove!(*args)
    removed_tags = extract_tokens(*args)
    @list -= removed_tags

    taggings.joins(:tag).where(tags: { label: removed_tags }).readonly(false).destroy_all
  end

  def clear
    @list.clear
    taggings.each(&:mark_for_destruction)
  end

  def clear!
    @list.clear
    taggings.destroy_all
  end

  private
  def extract_tokens(*args)
    args.flat_map do |arg|
      if arg.respond_to?(:to_a)
        arg.to_a.map(&:to_s)
      else
        arg.to_s.split(separator)
      end
    end
  end

  def add_raw(added_tags)
    added_tags.each do |token|
      if taggings.reject(&:marked_for_destruction?).none? { |tagging| tagging.label == token.to_s }
        taggings.build(tag: Tag[token])
      end
    end
  end

  def add_raw!(added_tags)
    Tag.transaction do
      added_tags.each do |label|
        tag = Tag.find_or_create_by!(label: label)
        taggings.find_or_create_by!(tag: tag)
      end
    end
  end
end