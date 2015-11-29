# == Schema Information
#
# Table name: attachments
#
#  id                :integer          not null, primary key
#  asset             :string
#  content_type      :string
#  file_size         :integer
#  asset_updated_at  :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  author_id         :integer
#  original_filename :string
#  asset_token       :string           not null
#  downloads_count   :integer          default(0), not null
#

class Attachment < ActiveRecord::Base
  include CounterIncrementable
  include FileAttachable
  include Ownable
  include PeriodFilterable
  include PersistenceContextTrackable
  include TitleSearchable
  include Translatable

  translates :title, :description, fallbacks_for_empty_translations: true

  has_attachment
  has_owner :author, default_owner_to_current_user: false

  has_many :image_attachments, class_name: 'Image::Attachment',
                               inverse_of: :attachment, dependent: :destroy

  validates :asset, presence: true

  before_validation :set_default_title, on: :create

  def image?
    content_type.in?(Image.permitted_content_types)
  end

  delegate :themepack?, to: :file_extension

  def to_image
    fail 'cannot be converted to Image' unless image?
    Image.new do |image|
      image.asset = asset
      image.original_filename = original_filename
      image.content_type = content_type
      image.file_size = file_size
      image.asset_updated_at = asset_updated_at
      image.author_id = author_id
      translated_locales.each do |translated_locale|
        Globalize.with_locale(translated_locale) do
          image.title = title
          image.description = description
        end
      end
    end
  end

  private

  def set_default_title
    return if title.present? || original_filename.blank?
    self.title = File.basename(original_filename, '.*').titleize
  end
end

require_dependency 'image/attachment'
