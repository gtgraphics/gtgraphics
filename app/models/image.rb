# == Schema Information
#
# Table name: images
#
#  id                          :integer          not null, primary key
#  asset                       :string(255)
#  content_type                :string(255)
#  file_size                   :integer
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
#  original_filename           :string(255)
#  asset_token                 :string(255)      not null
#

class Image < ActiveRecord::Base
  include Image::Attachable
  include Image::Croppable
  include Image::ExifStorable
  include Ownable
  include PersistenceContextTrackable
  include Sortable
  include Taggable
  include Translatable

  # Disallow changing the asset as all custom_styles depend on it
  attr_readonly :asset, :content_type, :file_size

  has_many :custom_styles, class_name: 'Image::Style', inverse_of: :image, dependent: :destroy
  has_many :image_pages, class_name: 'Page::Image', inverse_of: :image, dependent: :destroy
  has_many :pages, through: :image_pages

  has_image
  has_owner :author, default_owner_to_current_user: false
  
  store :predefined_style_dimensions

  translates :title, :description, fallbacks_for_empty_translations: true
  sanitizes :title, with: :squish

  validates :title, presence: true

  # before_save :set_predefined_style_dimensions
  after_initialize :generate_asset_token, unless: :asset_token?
  before_validation :set_default_title, on: :create
  before_save :set_geometry, if: :asset_changed?
  before_update :destroy_custom_styles, if: :asset_changed?

  acts_as_sortable do |by|
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.title(default: true) { |column, dir| Image::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
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

  def generate_asset_token
    self.asset_token = SecureRandom.uuid
  end

  # def set_predefined_style_dimensions
  #   predefined_style_dimensions_will_change! if asset.queued_for_write[:original]
  #   self.predefined_style_dimensions ||= {}
  #   STYLES.except(:custom).keys.each do |style_name|
  #     style_file = asset.queued_for_write[style_name]
  #     if style_file
  #       geometry = Paperclip::Geometry.from_file(style_file.path)
  #       dimensions = geometry.width.to_i, geometry.height.to_i
  #       self.predefined_style_dimensions[style_name] = dimensions
  #     end
  #   end
  # end

  def set_default_title
    if title.blank? and original_filename.present?
      self.title = File.basename(original_filename, '.*').titleize
    end
  end

  def set_geometry
    original_path = asset.path
    custom_path = asset.versions[:custom].path
    
    original_img = MiniMagick::Image.open(original_path)
    self.original_width = original_img[:width]
    self.original_height = original_img[:height]

    custom_img = MiniMagick::Image.open(custom_path)
    self.width = custom_img[:width]
    self.height = custom_img[:height]
  end
end
