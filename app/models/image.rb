# == Schema Information
#
# Table name: images
#
#  id                          :integer          not null, primary key
#  asset_file_name             :string(255)
#  asset_content_type          :string(255)
#  asset_file_size             :integer
#  asset_updated_at            :datetime
#  width                       :integer
#  height                      :integer
#  exif_data                   :text
#  created_at                  :datetime
#  updated_at                  :datetime
#  author_id                   :integer
#  customization_options       :text
#  transformed_width           :integer
#  transformed_height          :integer
#  predefined_style_dimensions :text
#

class Image < ActiveRecord::Base
  include Authorable
  # include AttachmentPreservable
  include BatchTranslatable
  include ImageContainable
  include ImageCroppable
  include PersistenceContextTrackable
  include Sortable
  include Taggable

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
  has_many :image_pages, class_name: 'Page::Image', dependent: :destroy
  has_many :pages, through: :image_pages

  translates :title, :description, fallbacks_for_empty_translations: true

  serialize :exif_data, OpenStruct
  store :customization_options
  store :predefined_style_dimensions

  acts_as_authorable default_to_current_user: false
  acts_as_batch_translatable
  acts_as_image_containable styles: ->(attachment) { attachment.instance.convert_styles },
                            url: '/system/images/:id/:style.:extension'
  acts_as_image_croppable
  acts_as_sortable do |by|
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.title(default: true) { |column, dir| Image::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
  end

  # preserve_attachment_between_requests_for :asset

  validates_attachment :asset, presence: true, content_type: { content_type: CONTENT_TYPES }

  after_initialize :set_transformation_defaults, if: :new_record?
  before_validation :set_default_title, on: :create
  before_save :set_predefined_style_dimensions
  with_options if: :asset_changed? do |image|
    image.after_validation :set_transformation_defaults
    image.before_save :set_transformed_dimensions
    image.before_save :set_exif_data
    image.before_update :destroy_custom_styles
  end

  has_dimensions :transformed_dimensions, from: [:transformed_width, :transformed_height]

  delegate :software, to: :exif_data, allow_nil: true

  class << self
    def content_types
      CONTENT_TYPES
    end

    def predefined_style_names
      STYLES.keys.inject({}) do |style_names, style_name|
        style_names.merge!(style_name.to_s => I18n.translate(style_name, scope: 'image.predefined_styles'))
      end
    end

    def search(query)
      if query.present?
        terms = query.to_s.split.uniq.map { |term| "%#{term}%" }
        # we go over taggings association here, because we probably want to include tags manually
        ransack(translations_title_or_taggings_tag_label_matches_any: terms).result
      else
        all
      end
    end
  end
  
  def asset_path(style = :transformed)
    asset.path(style)
  end

  def asset_url(style = :transformed)
    asset.url(style)
  end
  
  def camera
    exif_data.try(:model)
  end

  def convert_styles
    STYLES.reverse_merge(custom_convert_styles).deep_symbolize_keys
  end

  def custom_convert_styles
    custom_styles.inject({}) do |custom_styles, style|
      custom_styles.merge!(style.label => style.transformations) if style.variant? and style.persisted? and !style.marked_for_destruction?
      custom_styles
    end
  end

  def predefined_styles
    STYLES.except(:transformed).keys.map { |style_name| Image::Style::Predefined.new(self, style_name) }
  end

  def styles
    predefined_styles + custom_styles
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

  def set_predefined_style_dimensions
    predefined_style_dimensions_will_change! if asset.queued_for_write[:original]
    self.predefined_style_dimensions ||= {}
    STYLES.except(:transformed).keys.each do |style_name|
      if style_file = asset.queued_for_write[style_name]
        geometry = Paperclip::Geometry.from_file(style_file.path)
        width, height = geometry.width.to_i, geometry.height.to_i
        predefined_style_dimensions[style_name] = ImageDimensions.new(width, height)
      end
    end
  end

  def set_transformation_defaults
    self.cropped = false if cropped.nil?
  end

  def set_transformed_dimensions
    self.transformed_dimensions = cropped? ? [crop_width, crop_height] : dimensions
  end
end
