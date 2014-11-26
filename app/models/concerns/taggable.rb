module Taggable
  extend ActiveSupport::Concern

  included do
    include Excludable

    has_many :taggings, as: :taggable, dependent: :destroy, autosave: true
    has_many :tags, through: :taggings

    validate :verify_tag_list_validity
  end

  module ClassMethods
    def tagged(*tokens)
      options = tokens.extract_options!.reverse_merge(any: false, fuzzy: false)
      if options[:any]
        tagged_any(*tokens)
      else
        tagged_all(*tokens)
      end
    end

    private
    def tagged_all(*tokens)
      options = tokens.extract_options!
      scope = joins(:tags).readonly(false).uniq
      tokens = tokens.flatten.uniq
      label = Tag.arel_table[:label]
      conditions = tokens.map do |token|
        if options[:fuzzy]
          match = label.matches(token)
        else
          match = label.eq(token)
        end
        arel_table[:id].in(
          Tagging.joins(:tag).where(match).
          select(Tagging.arel_table[:taggable_id]).ast
        )
      end.reduce(:and)
      scope.where(conditions)
    end

    def tagged_any(*tokens)
      options = tokens.extract_options!
      tokens = tokens.flatten.uniq
      value = tokens.one? ? tokens.first : tokens
      label = Tag.arel_table[:label]
      if options[:fuzzy]
        match = label.matches(value)
      else
        match = label.eq(value)
      end
      joins(:tags).where(match).readonly(false).uniq
    end
  end

  def tag_list
    @tag_list ||= TagCollection.new(self)
  end
  
  def tag_list=(tokens)
    tag_list.set(tokens)
  end


  # Inquiries

  def tagged?(*tokens)
    options = labels.extract_options!.reverse_merge(any: false)
    tokens.flatten.public_send(options[:any] ? 'any?' : 'all?') do |token|
      token.to_s.in?(tag_list.to_a)
    end
  end


  # Tag / Untag

  def tag(*labels)
    tag_list.add(labels)
  end

  def tag!(*labels)
    tag_list.add!(labels)
  end

  def untag(*labels)
    tag_list.remove(labels)
  end

  def untag!(*labels)
    tag_list.remove!(labels)
  end


  # Relatives

  def relatives
    self_and_relatives.without(self)
  end

  def self_and_relatives
    self.class.tagged_all(tag_tokens.to_a)
  end

  def similar
    self_and_similar.without(self)
  end

  def self_and_similar
    self.class.tagged_any(tag_tokens.to_a)
  end

  private
  def verify_tag_list_validity
    if taggings.any? { |tagging| tagging.errors.any? }
      errors.add(:tag_list, :contains_invalid)
    end
  end
end