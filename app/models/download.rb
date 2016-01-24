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

class Download < Hit
  self.counter_cache = :downloads_count

  delegate :asset, :title, :file_size, :content_type, :file_extension,
           to: :downloadable

  scope :attachments, -> { where(downloadable_type: 'Attachment') }
  scope :image_styles, -> { where(downloadable_type: 'Image::Style') }

  alias_attribute :downloadable_type, :hittable_type
  alias_attribute :downloadable_id, :hittable_id

  def attachment?
    downloadable_type == 'Attachment'
  end

  def image_style?
    downloadable_type == 'Image::Style'
  end
end
