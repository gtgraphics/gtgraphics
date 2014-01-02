# == Schema Information
#
# Table name: images
#
#  id                    :integer          not null, primary key
#  asset_file_name       :string(255)
#  asset_content_type    :string(255)
#  asset_file_size       :integer
#  asset_updated_at      :datetime
#  width                 :integer
#  height                :integer
#  exif_data             :text
#  created_at            :datetime
#  updated_at            :datetime
#  author_id             :integer
#  customization_options :text
#

class Image < ActiveRecord::Base
  include Authorable
  # include AttachmentPreservable
  include BatchTranslatable
  include HtmlContainable
  include ImageContainable
  include ImageCroppable
  include PageEmbeddable
  include PersistenceContextTrackable
  include Sortable
  include Templatable

  CONTENT_TYPES = ImageContainable::CONTENT_TYPES
  EXIF_CAPABLE_CONTENT_TYPES = [Mime::JPEG].freeze

  STYLES = {
    original_cropped: { geometry: '100%x100%', processors: [:manual_cropper] },
    thumbnail: { geometry: '75x75#', format: :png, processors: [:manual_cropper] },
    large_thumbnail: { geometry: '253x190#', format: :png, processors: [:manual_cropper] },
    preview: { geometry: '1170x>', processors: [:manual_cropper] },
    medium: { geometry: '1280x780', processors: [:manual_cropper] },
    large: { geometry: '1920x1080', processors: [:manual_cropper] }
  }.freeze

  self.template_type = 'Template::Image'.freeze

  attr_readonly :type

  has_many :custom_styles, class_name: 'Image::Style', autosave: true, inverse_of: :image, dependent: :destroy

  translates :title, :description, fallbacks_for_empty_translations: true

  store :customization_options, accessors: [:crop_x, :crop_y, :crop_width, :crop_height]

  acts_as_authorable default_to_current_user: false
  acts_as_batch_translatable
  acts_as_html_containable :description
  acts_as_image_containable styles: ->(attachment) { attachment.instance.styles },
                            url: '/system/images/:id/:style.:extension'
  acts_as_page_embeddable multiple: true, destroy_with_page: false
  acts_as_sortable do |by|
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.title(default: true) { |column, dir| Image::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
  end
  # preserve_attachment_between_requests_for :asset

  serialize :exif_data, OpenStruct

  validates_attachment :asset, presence: true, content_type: { content_type: ImageContainable::CONTENT_TYPES }

  before_validation :set_default_title
  before_save :set_exif_data, if: :asset_changed?
  before_update :destroy_custom_styles, if: :asset_changed?

  class << self
    def content_types
      ImageContainable::CONTENT_TYPES
    end
  end

  %w(crop_x crop_y crop_width crop_height).each do |method|
    class_eval %{
      def #{method}=(value)
        super(value.to_i)
      end
    }
  end

  def custom_styles_hash
    self.custom_styles.inject({}) do |custom_styles, custom_style|
      if custom_style.variation? and custom_style.persisted?
        custom_styles.merge!(custom_style.label => custom_style.transformations)
      end
      custom_styles
    end
  end

  def styles
    STYLES.reverse_merge(custom_styles_hash).deep_symbolize_keys
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
  def destroy_custom_styles
    self.custom_styles.variations.destroy_all
  end

  def set_default_title
    translation.title = File.basename(asset_file_name, '.*').humanize if asset_file_name.present? and translation.title.blank?
  end

  def set_exif_data
    if asset_content_type.in?(EXIF_CAPABLE_CONTENT_TYPES)
      self.exif_data = OpenStruct.new(EXIFR::JPEG.new(asset.queued_for_write[:original].path).to_hash) rescue nil
    end
  end
end
