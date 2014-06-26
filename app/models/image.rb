# == Schema Information
#
# Table name: images
#
#  id                          :integer          not null, primary key
#  asset_file_name             :string(255)
#  asset_content_type          :string(255)
#  asset_file_size             :integer
#  asset_updated_at            :datetime
#  original_width              :integer
#  original_height             :integer
#  exif_data                   :text
#  created_at                  :datetime
#  updated_at                  :datetime
#  author_id                   :integer
#  customization_options       :text
#  width                       :integer
#  height                      :integer
#  predefined_style_dimensions :text
#

class Image < ActiveRecord::Base
  include Image::AssetContainable
  include Image::Croppable
  include Image::ExifStorable
  include Ownable
  include PersistenceContextTrackable
  include Sortable
  include Taggable

  STYLES = {
    custom: { geometry: '100%x100%', processors: [:manual_cropper] },
    thumbnail: { geometry: '75x75#', format: :png, processors: [:manual_cropper] },
    large_thumbnail: { geometry: '253x190#', format: :png, processors: [:manual_cropper] },
    preview: { geometry: '1170x>', processors: [:manual_cropper] },
    medium: { geometry: '1280x780', processors: [:manual_cropper] },
    large: { geometry: '1920x1080', processors: [:manual_cropper] },
    social: { geometry: '1500x1500#', format: :jpg, processors: [:manual_cropper] },
    page_preview: { geometry: '780x150#', format: :jpg, processors: [:manual_cropper] }
  }.freeze

  has_many :custom_styles, class_name: 'Image::Style', inverse_of: :image, dependent: :destroy
  has_many :image_pages, class_name: 'Page::Image', dependent: :destroy
  has_many :pages, through: :image_pages

  has_image styles: ->(attachment) { attachment.instance.convert_styles },
            default_style: :custom,
            url: '/system/images/:id/:style.:extension'
  
  has_owner :author, default_owner_to_current_user: false

  translates :title, :description, fallbacks_for_empty_translations: true

  store :predefined_style_dimensions

  acts_as_sortable do |by|
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.title(default: true) { |column, dir| Image::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
  end

  # preserve_attachment_between_requests_for :asset

  after_initialize :set_transformation_defaults, if: :new_record?
  before_validation :set_default_title, on: :create
  before_save :set_predefined_style_dimensions
  with_options if: :asset_changed? do |image|
    image.after_validation :set_transformation_defaults
    image.before_save :set_transformed_dimensions
    image.before_save :set_exif_data
    image.before_update :destroy_custom_styles
  end

  class << self
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

  def to_param
    "#{id}-#{title.parameterize}"
  end

  def to_s
    title
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
