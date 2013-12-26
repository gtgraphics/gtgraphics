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
#  author_id          :integer
#  crop_x             :integer
#  crop_y             :integer
#  crop_width         :integer
#  crop_height        :integer
#

class Image < ActiveRecord::Base
  include Authorable
  # include AttachmentPreservable
  include BatchTranslatable
  include ImageContainable
  include ImageCroppable
  include PageEmbeddable
  include PersistenceContextTrackable
  include Sortable
  include Templatable

  CONTENT_TYPES = ImageContainable::CONTENT_TYPES
  EXIF_CAPABLE_CONTENT_TYPES = [Mime::JPEG].freeze

  STYLES = {
    original_cropped: { geometry: '100%x100%' },
    thumbnail: { geometry: '75x75#', format: :png },
    large_thumbnail: { geometry: '253x190#', format: :png },
    preview: { geometry: '1170x' },
    medium: { geometry: '1280x780' },
    large: { geometry: '1920x1080' }
  }.freeze

  RESOLUTION_PRESETS = {
    '720p' => '1280x720',
    '1080p' => '1920x1080',
    'wuxga' => '1920x1200',
    '2k' => '2048x1536',
    '4k' => '4096x3072'
  }.freeze

  self.template_type = 'Template::Image'.freeze

  has_many :styles, class_name: 'Image::Style', dependent: :destroy

  translates :title, :description, fallbacks_for_empty_translations: true

  acts_as_authorable default_to_current_user: false
  acts_as_batch_translatable
  acts_as_image_containable styles: STYLES, url: '/system/images/:id/:style.:extension', processors: [:manual_cropper]
  acts_as_page_embeddable multiple: true, destroy_with_page: false
  acts_as_sortable do |by|
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.title(default: true) { |column, dir| Image::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
  end
  # preserve_attachment_between_requests_for :asset

  serialize :exif_data, OpenStruct

  before_validation :set_default_title
  before_save :set_exif_data, if: :asset_changed?

  class << self
    def content_types
      CONTENT_TYPES
    end
  end

  def description_html
    template = Liquid::Template.parse(description)
    template.render(to_liquid).html_safe
  end

  def to_liquid
    {} # TODO
  end

  def to_param
    "#{id}-#{title.parameterize}"
  end

  def to_s
    title
  end

  private
  def set_default_title
    translation.title = File.basename(asset_file_name, '.*').humanize if asset_file_name.present? and translation.title.blank?
  end

  def set_exif_data
    if asset_content_type.in?(EXIF_CAPABLE_CONTENT_TYPES)
      self.exif_data = OpenStruct.new(EXIFR::JPEG.new(asset.queued_for_write[:original].path).to_hash) rescue nil
    end
  end
end
