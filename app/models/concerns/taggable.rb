module Taggable
  extend ActiveSupport::Concern

  TOKEN_OPTIONS = {
    sort: true,
    unique: true
  }.freeze

  included do
    include Excludable

    has_many :taggings, as: :taggable, dependent: :destroy, autosave: true
    has_many :tags, through: :taggings

    validate :verify_tag_tokens_validity
  end

  module ClassMethods
    def tagged(*labels)
      scope = joins(:tags).readonly(false).uniq
      labels = labels.flatten.uniq
      if labels.one?
        scope.where(tags: { label: labels.first })
      else
        conditions = labels.map do |label|
          arel_table[:id].in(
            Tagging.joins(:tag).where(tags: { label: label }).
            select(Tagging.arel_table[:taggable_id]).ast
          )
        end.reduce(:and)
        scope.where(conditions)
      end
    end
    alias_method :tagged_all, :tagged

    def tagged_any(*labels)
      labels = labels.flatten.uniq
      joins(:tags).where(tags: { label: labels.one? ? labels.first : labels }).readonly(false).uniq
    end
  end

  def tag_tokens
    @tag_tokens ||= TokenCollection.new(self.tags.pluck(:label), TOKEN_OPTIONS)
  end
  
  def tag_tokens=(labels)
    @tag_tokens = TokenCollection.new(labels, TOKEN_OPTIONS)
    labels = @tag_tokens.to_a
    labels.each do |label|
      if self.taggings.none? { |tagging| tagging.label == label.to_s }
        tag = Tag.find_or_initialize_by(label: label)
        self.taggings.build(tag: tag)
      end
    end
    self.taggings.reject { |tagging| tagging.label.in?(labels) }.each(&:mark_for_destruction)
  end


  # Inquiries

  def tagged?(*labels)
    labels.flatten.all? { |label| label.to_s.in?(tag_tokens.to_a) }
  end
  alias_method :all_tagged?, :tagged?

  def any_tagged?(*labels)
    labels.flatten.any? { |label| label.to_s.in?(tag_tokens.to_a) }
  end


  # Tag / Untag

  def tag(*labels)
    self.tag_tokens += labels
  end

  def tag!(*labels)
    transaction do
      labels.flatten.uniq.each do |label|
        tag = Tag.find_or_create_by!(label: label)
        self.taggings.find_or_create_by!(tag: tag)
      end
    end
  end

  def untag(*labels)
    self.tag_tokens -= labels
  end

  def untag!(*labels)
    self.taggings.joins(:tag).where(tags: { label: labels.flatten.uniq }).readonly(false).destroy_all
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
  def verify_tag_tokens_validity
    if taggings.any? { |tagging| tagging.errors.any? }
      errors.add(:tag_tokens, :contains_invalid)
    end
  end
end