module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :delete_all, autosave: true
    has_many :tags, through: :taggings

    validate :verify_tag_tokens_validity
  end

  module ClassMethods
    def tagged(label)
      joins(:tags).where(tags: { label: label }).readonly(false)
    end
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

  private
  def verify_tag_tokens_validity
    if taggings.any? { |tagging| tagging.errors.any? }
      errors.add(:tag_tokens, :contains_invalid)
    end
  end
end