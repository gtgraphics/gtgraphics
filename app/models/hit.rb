# == Schema Information
#
# Table name: hits
#
#  id            :integer          not null, primary key
#  hittable_id   :integer          not null
#  hittable_type :string           not null
#  created_at    :datetime         not null
#  referer       :string
#  user_agent    :string
#  type          :string
#  ip            :string(11)
#

class Hit < ActiveRecord::Base
  include TimeFilterable

  class_attribute :counter_cache

  belongs_to :hittable, required: true, polymorphic: true

  after_create :increment_hits_count, if: :hittable_has_counter_cache?
  after_destroy :decrement_hits_count, if: :hittable_has_counter_cache?

  def self.in_current_month
    date = Date.today
    by_month(date.year, date.month)
  end

  def self.in_previous_month
    date = Date.today - 1.month
    by_month(date.year, date.month)
  end

  private

  def increment_hits_count
    change_hits_count(:+)
  end

  def decrement_hits_count
    change_hits_count(:-)
  end

  def change_hits_count(sign)
    hittable.class.where(hittable.class.primary_key => hittable_id).update_all(
      "#{counter_cache} = COALESCE(#{counter_cache}, 0) #{sign} 1"
    )
  end

  def hittable_has_counter_cache?
    hittable.class.column_names.include?(counter_cache.to_s)
  end
end
