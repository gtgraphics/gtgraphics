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
  include TimeFilterable

  COUNTER_CACHE = :downloads_count

  belongs_to :downloadable, required: true, polymorphic: true

  delegate :asset, :title, :file_size, :content_type, :file_extension,
           to: :downloadable

  after_create :increment_downloads_count, if: :downloadable_has_counter_cache?
  after_destroy :decrement_downloads_count, if: :downloadable_has_counter_cache?

  scope :attachments, -> { where(downloadable_type: 'Attachment') }
  scope :image_styles, -> { where(downloadable_type: 'Image::Style') }

  def self.in_current_month
    date = Date.today
    by_month(date.year, date.month)
  end

  def self.in_previous_month
    date = Date.today - 1.month
    by_month(date.year, date.month)
  end

  def attachment?
    downloadable_type == 'Attachment'
  end

  def image_style?
    downloadable_type == 'Image::Style'
  end

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
