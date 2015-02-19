module Taggable
  extend ActiveSupport::Concern

  included do
    include Excludable

    has_many :taggings, as: :taggable, dependent: :destroy, autosave: true
    has_many :tags, through: :taggings

    validate :verify_tag_list_validity
  end

  module ClassMethods
    def available_tags
      Tag.joins(:taggings).where(taggings: { taggable_type: self.name }).uniq
    end

    def tagged(*tokens)
      options = tokens.extract_options!
      tokens = tokens.flatten.reject(&:blank?)
      return all if tokens.empty?
      if options.fetch(:any, false)
        tagged_any(tokens)
      else
        tagged_all(tokens)
      end
    end

    def tag!(*tokens)
      transaction do
        find_each { |record| record.tag!(tokens) }
      end
      tokens
    end

    def untag!(*tokens)
      transaction do
        find_each { |record| record.untag!(tokens) }
      end
      tokens
    end

    private
    def tagged_all(tokens)
      conditions = tokens.map do |token|
        arel_table[:id].in(
          Tagging.joins(:tag).where(tags: { label: token }).
          select(Tagging.arel_table[:taggable_id]).ast
        )
      end.reduce(:and)
      joins(:tags).readonly(false).uniq.where(conditions)
    end

    def tagged_any(tokens)
      joins(:tags).where(tags: { label: tokens }).readonly(false).uniq
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
    options = tokens.extract_options!.reverse_merge(any: false)
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
    return if taggings.none? { |tagging| tagging.errors.any? }
    errors.add(:tag_list, :contains_invalid)
  end
end
