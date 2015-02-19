module NestedSetRepresentable
  extend ActiveSupport::Concern

  included do
    include Excludable

    acts_as_nested_set counter_cache: :children_count, dependent: :destroy

    validate :verify_parent_assignability, if: :parent_id_changed?
  end

  module ClassMethods
    def assignable_as_parent_of(record_or_id)
      if record_or_id.present?
        if record_or_id.is_a?(self.class)
          record = record_or_id
        else
          record = self.unscoped.find(record_or_id)
        end
        without(record, record.descendants)
      else
        all
      end
    end
  end

  def ancestors_and_siblings
    self.class.where(parent_id: self.ancestors.ids << nil)
  end

  def descendants_count
    self_and_descendants.pluck(:children_count).sum
  end

  def self_and_ancestors_and_siblings
    self.class.where(parent_id: self.self_and_ancestors.ids << nil)
  end

  private
  def verify_parent_assignability
    errors.add(:parent_id, :invalid) if self_and_descendants.pluck(:id).include?(parent_id)
  end
end
