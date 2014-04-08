module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :delete_all, autosave: true
    has_many :tags, through: :taggings

    validate :verify_tag_tokens_validity
  end

  module ClassMethods
    def tagged(*labels)
      scope = joins(:tags).readonly(false)
      labels = labels.flatten.uniq
      if labels.one?
        scope.where(tags: { label: labels.first })
      else
        conditions = labels.map { |label| Tag.where(label: label).exists }.reduce(:and)
        scope.where(conditions).uniq
      end
    end
    alias_method :tagged_all, :tagged

    def tagged_any(*labels)
      labels = labels.flatten.uniq
      joins(:tags).where(tags: { label: labels.one? ? labels.first : labels }).readonly(false)
    end
  end

  def tag(*labels)
    transaction do
      labels.flatten.uniq.each do |label|
        tag = Tag.find_or_create_by(label: label)
        self.taggings.find_or_create_by(tag: tag)
      end
    end
  end

  def tagged?(*labels)
    labels.flatten.all? { |label| label.to_s.in?(tag_tokens.to_a) }
  end
  alias_method :tagged_all?, :tagged?

  def tagged_any?(*labels)
    labels.flatten.any? { |label| label.to_s.in?(tag_tokens.to_a) }
  end

  def tag_tokens
    @tag_tokens ||= TokenCollection.new(self.tags.pluck(:label), sort: true, unique: true)
  end
  
  def tag_tokens=(labels)
    @tag_tokens = TokenCollection.new(labels, sort: true, unique: true)
    labels = @tag_tokens.to_a
    labels.each do |label|
      if self.taggings.none? { |tagging| tagging.label == label }
        tag = Tag.find_or_initialize_by(label: label)
        self.taggings.build(tag: tag)
      end
    end
    self.taggings.reject { |tagging| tagging.label.in?(labels) }.each(&:mark_for_destruction)
  end

  def untag(*labels)
    self.taggings.joins(:tag).where(tags: { label: labels.to_a.flatten.uniq }).readonly(false).destroy_all
  end

  private
  def verify_tag_tokens_validity
    if taggings.any? { |tagging| tagging.errors.any? }
      errors.add(:tag_tokens, :contains_invalid)
    end
  end
end