# == Schema Information
#
# Table name: images
#
#  id                    :integer          not null, primary key
#  asset                 :string
#  content_type          :string
#  file_size             :integer
#  asset_updated_at      :datetime
#  original_width        :integer
#  original_height       :integer
#  exif_data             :text
#  created_at            :datetime
#  updated_at            :datetime
#  author_id             :integer
#  customization_options :text
#  width                 :integer
#  height                :integer
#  original_filename     :string
#  asset_token           :string           not null
#  shop_urls             :text
#

class Image < ActiveRecord::Base
  include Image::Attachable
  include Image::Croppable
  include Image::Resizable
  include Image::ProjectAssignable
  include Image::ExifStorable

  include Filterable
  include Ownable
  include PagePropagatable
  include PeriodFilterable
  include PersistenceContextTrackable
  include Randomizable
  include Taggable
  include TitleSearchable
  include Translatable

  COPYRIGHT_NOTE = 'Copyright %{year} %{author}, GTGRAPHICS. ' \
                   'All rights reserved.'

  has_many :styles, class_name: 'Image::Style', inverse_of: :image,
                    dependent: :destroy
  has_many :image_attachments, class_name: 'Image::Attachment',
                               inverse_of: :image, dependent: :destroy
  has_many :image_pages, class_name: 'Page::Image', inverse_of: :image,
                         dependent: :destroy
  has_many :pages, through: :image_pages
  has_many :buy_requests, class_name: 'Message::BuyRequest',
                          foreign_key: :delegator_id, dependent: :destroy
  has_many :shop_links, class_name: 'Image::ShopLink', inverse_of: :image,
                        dependent: :delete_all
  has_many :buy_requests, class_name: 'Message::BuyRequest',
                          foreign_key: :delegator_id, dependent: :destroy

  has_image
  acts_as_croppable
  acts_as_resizable

  has_owner :author, default_owner_to_current_user: false

  translates :title, :description, fallbacks_for_empty_translations: true
  sanitizes :title, with: :squish

  validates :asset, presence: true
  validates :title, presence: true

  before_validation :set_default_title, on: :create
  before_create :set_author, unless: :author_id?
  after_update :destroy_styles, if: :asset_changed?
  after_save :write_copyright!, if: [:exif_capable?, :write_copyright?]

  scope :landscape, -> { where(arel_table[:width].gteq(arel_table[:height])) }
  scope :portrait, -> { where(arel_table[:width].lt(arel_table[:height])) }

  def dominant_colors
    @dominant_colors ||= Miro::DominantColors.new(asset.custom.path)
  end

  def manipulated?
    cropped? || resized?
  end

  def to_attachment(version = :custom)
    Attachment.new do |attachment|
      attachment.asset = asset.versions.fetch(version.to_sym) do
        fail ArgumentError, "unknown version: #{version}"
      end.file
      attachment.original_filename = original_filename
      attachment.content_type = content_type
      attachment.file_size = file_size
      attachment.asset_updated_at = asset_updated_at
      attachment.author_id = author_id
      translated_locales.each do |translated_locale|
        Globalize.with_locale(translated_locale) do
          attachment.title = title
          attachment.description = description
        end
      end
    end
  end

  def to_s
    title
  end

  # Copyright

  def copyright_note
    COPYRIGHT_NOTE % { year: taken_at.try(:year) || created_at.year,
                       author: author.name }
  end

  def write_copyright!
    begin
      with_metadata :public do |metadata|
        metadata.copyright = copyright_note
        metadata.save!
      end
    rescue MiniExiftool::Error => error
      logger.error "Error writing Exif data: #{error.message}"
    end
    styles.each(&:write_copyright!)
  end

  private

  def set_author
    self.author = artist || User.current
  end

  def set_default_title
    return if title.present? || original_filename.blank?
    self.title = File.basename(original_filename, '.*').titleize
  end

  def write_copyright?
    author_id_changed? || asset_changed?
  end

  def destroy_styles
    styles.destroy_all
  end
end

require_dependency 'page/image'
require_dependency 'project/image'
