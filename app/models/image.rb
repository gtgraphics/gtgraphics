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
#  transformed_width     :integer
#  transformed_height    :integer
#

class Image < ActiveRecord::Base
  include Authorable
  # include AttachmentPreservable
  include BatchTranslatable
  include ImageContainable
  include ImageCroppable
  include PersistenceContextTrackable
  include Sortable

  CONTENT_TYPES = ImageContainable::CONTENT_TYPES
  EXIF_CAPABLE_CONTENT_TYPES = [Mime::JPEG].freeze

  STYLES = {
    transformed: { geometry: '100%x100%', processors: [:manual_cropper] },
    thumbnail: { geometry: '75x75#', format: :png, processors: [:manual_cropper] },
    large_thumbnail: { geometry: '253x190#', format: :png, processors: [:manual_cropper] },
    preview: { geometry: '1170x>', processors: [:manual_cropper] },
    medium: { geometry: '1280x780', processors: [:manual_cropper] },
    large: { geometry: '1920x1080', processors: [:manual_cropper] },
    social: { geometry: '1500x1500#', format: :jpg, processors: [:manual_cropper] },
    page_preview: { geometry: '780x150#', format: :jpg, processors: [:manual_cropper] }
  }.freeze

  has_many :custom_styles, class_name: 'Image::Style', autosave: true, inverse_of: :image, dependent: :destroy
  has_many :image_pages, class_name: 'Page::Image', dependent: :delete_all
  has_many :pages, through: :image_pages

  translates :title, :description, fallbacks_for_empty_translations: true

  store :customization_options, accessors: [:crop_x, :crop_y, :crop_width, :crop_height]

  acts_as_authorable default_to_current_user: false
  acts_as_batch_translatable
  acts_as_image_containable styles: ->(attachment) { attachment.instance.styles },
                            url: '/system/images/:id/:style.:extension'
  acts_as_image_croppable
  acts_as_sortable do |by|
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.title(default: true) { |column, dir| Image::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
  end

  # preserve_attachment_between_requests_for :asset

  serialize :exif_data, OpenStruct

  validates_attachment :asset, presence: true, content_type: { content_type: CONTENT_TYPES }

  after_initialize :set_transformation_defaults, if: :new_record?
  before_validation :set_default_title, on: :create
  with_options if: :asset_changed? do |image|
    image.after_validation :set_transformation_defaults
    image.before_save :set_transformed_dimensions
    image.before_save :set_exif_data
    image.before_update :destroy_custom_styles
  end

  delegate :path, :url, to: :asset
  delegate :software, to: :exif_data, allow_nil: true

  class << self
    def content_types
      CONTENT_TYPES
    end
  end

  %w(crop_x crop_y crop_width crop_height).each do |method|
    class_eval %{
      def #{method}=(value)
        super(value.try(:to_i))
      end
    }
  end

  def camera
    exif_data.try(:model)
  end

  def custom_styles_hash
    self.custom_styles.inject({}) do |custom_styles, style|
      custom_styles.merge!(style.label => style.transformations) if style.variant? and style.persisted? and !style.marked_for_destruction?
      custom_styles
    end
  end

  def styles
    STYLES.reverse_merge(custom_styles_hash).deep_symbolize_keys
  end

  def taken_at
    exif_data.try(:date_time_original).try(:to_datetime)
  end

  def to_liquid
    attributes.slice(*%w(title width height updated_at)).merge(customization_options).merge(
      'author' => author,
      'file_name' => asset_file_name,
      'file_size' => asset_file_size,
      'format' => human_content_type
    )
  end

  def to_s
    title
  end

  def uncrop!
    update(cropped: false)
    asset.reprocess!
  end

  private
  def destroy_custom_styles
    # This actually destroys only the variants of the replaced image
    self.custom_styles.variants.destroy_all
  end

  def set_default_title
    if asset_file_name.present?
      generated_title = File.basename(asset_file_name, '.*').humanize
      translations.each do |translation|
        translation.title = generated_title if translation.title.blank?
      end
    end
  end

  def set_exif_data
    if asset_content_type.in?(EXIF_CAPABLE_CONTENT_TYPES)
      self.exif_data = OpenStruct.new(EXIFR::JPEG.new(asset.queued_for_write[:original].path).to_hash) rescue nil
    end
  end

  def set_transformation_defaults
    self.cropped = false if cropped.nil?
  end

  def set_transformed_dimensions
    if cropped?
      self.transformed_width = crop_width
      self.transformed_height = crop_height
    else
      self.transformed_width = width
      self.transformed_height = height
    end
  end
end
