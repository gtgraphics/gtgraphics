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

  # Disallow changing the asset as all custom_styles depend on it
  attr_readonly :asset_file_name, :asset_file_size, :asset_updated_at

  has_many :custom_styles, class_name: 'Image::Style', inverse_of: :image, dependent: :destroy
  has_many :image_pages, class_name: 'Page::Image', dependent: :destroy
  has_many :pages, through: :image_pages

  has_image styles: STYLES, default_style: :custom, url: '/system/images/:id/:style.:extension'
  has_owner :author, default_owner_to_current_user: false

  translates :title, :description, fallbacks_for_empty_translations: true

  store :predefined_style_dimensions

  acts_as_sortable do |by|
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.title(default: true) { |column, dir| Image::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
  end

  before_save :set_predefined_style_dimensions
  before_update :destroy_custom_styles, if: :asset_changed?

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

  def to_param
    "#{id}-#{title.parameterize}"
  end

  def to_s
    title
  end

  private
  # When changing the asset, all created custom styles will be removed as they
  # depend semantically on the original image
  def destroy_custom_styles
    custom_styles.destroy_all
  end

  def set_predefined_style_dimensions
    predefined_style_dimensions_will_change! if asset.queued_for_write[:original]
    self.predefined_style_dimensions ||= {}
    STYLES.except(:custom).keys.each do |style_name|
      style_file = asset.queued_for_write[style_name]
      if style_file
        geometry = Paperclip::Geometry.from_file(style_file.path)
        dimensions = geometry.width.to_i, geometry.height.to_i
        self.predefined_style_dimensions[style_name] = dimensions
      end
    end
  end
end
