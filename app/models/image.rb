# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  asset_file_name    :string(255)
#  asset_content_type :string(255)
#  asset_file_size    :integer
#  asset_updated_at   :datetime
#  width              :integer
#  height             :integer
#  exif_data          :text
#  created_at         :datetime
#  updated_at         :datetime
#

class Image < ActiveRecord::Base
  include AssetContainable
  # include AttachmentPreservable
  include BatchTranslatable
  include PageEmbeddable
  include Templatable

  STYLES = {
    thumbnail: ['75x75#', :png],
    preview: ['1170x', :jpeg],
    medium: ['1280x780', :jpeg],
    large: ['1920x1080', :jpeg]
  }

  self.template_type = 'Template::Image'.freeze

  translates :title, :description, fallbacks_for_empty_translations: true

  has_attached_file :asset, styles: STYLES, url: '/system/:class/:id_partition/:style.:extension'

  acts_as_batch_translatable
  acts_as_page_embeddable multiple: true, destroy_with_page: false
  # preserve_attachment_between_requests_for :asset

  serialize :exif_data, OpenStruct

  before_validation :set_default_title
  before_save :set_dimensions, if: :asset_changed?
  before_save :set_exif_data, if: :asset_changed?

  validates :title, presence: true, uniqueness: true
  validates_attachment :asset, presence: true, content_type: { content_type: %w(image/jpeg image/pjpeg image/gif image/png) }

  alias_attribute :file_name, :asset_file_name
  alias_attribute :content_type, :asset_content_type
  alias_attribute :file_size, :asset_file_size

  def asset_changed?
    !asset.queued_for_write[:original].nil?
  end

  def aspect_ratio
    Rational(width, height)
  end

  def description_html(locale = I18n.locale)
    template = Liquid::Template.parse(self.description(locale))
    template.render(to_liquid).html_safe
  end

  def pixels
    width * height
  end

  def to_liquid
    {} # TODO
  end

  def to_s
    title
  end

  private
  def set_default_title
    translation.title = File.basename(asset_file_name, '.*').humanize if translation.title.blank?
  end

  def set_dimensions
    geometry = Paperclip::Geometry.from_file(asset.queued_for_write[:original].path)
    self.width = geometry.width.to_i
    self.height = geometry.height.to_i
  end

  def set_exif_data
    if asset_content_type.in? %w(image/jpeg image/pjpeg)
      self.exif_data = OpenStruct.new(EXIFR::JPEG.new(asset.queued_for_write[:original].path).to_hash) rescue nil
    end
  end
end
