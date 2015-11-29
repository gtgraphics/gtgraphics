# == Schema Information
#
# Table name: downloads
#
#  id                :integer          not null, primary key
#  downloadable_id   :integer          not null
#  downloadable_type :string           not null
#  created_at        :datetime         not null
#  referer           :string
#  user_agent        :string
#

class Download < ActiveRecord::Base
  COUNTER_CACHE = :downloads_count

  belongs_to :downloadable, required: true, polymorphic: true

  after_create :increment_downloads_count, if: :downloadable_has_counter_cache?
  after_destroy :decrement_downloads_count, if: :downloadable_has_counter_cache?

  private

  def increment_downloads_count
    change_downloads_count(:+)
  end

  def decrement_downloads_count
    change_downloads_count(:-)
  end

  def change_downloads_count(sign)
    downloadable.class.where(downloadable.class.primary_key => downloadable_id)
      .update_all("#{COUNTER_CACHE} = COALESCE(#{COUNTER_CACHE}, 0) #{sign} 1")
  end

  def downloadable_has_counter_cache?
    downloadable.class.column_names.include?(COUNTER_CACHE.to_s)
  end
end
