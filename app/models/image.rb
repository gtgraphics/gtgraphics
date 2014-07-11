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
  include Image::Resizable
  include Image::ExifStorable
  include Ownable
  include PeriodFilterable
  include PersistenceContextTrackable
  include Sortable
  include Taggable
  include Translatable

  # Disallow changing the asset as all custom_styles depend on it
  attr_readonly :asset

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

  acts_as_sortable do |by|
    by.title(default: true) { |column, dir| Image::Translation.arel_table[column].send(dir.to_sym) }
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.created_at
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

  def dominant_colors
    @dominant_colors ||= Miro::DominantColors.new(asset.path)
  end

  def manipulated?
    cropped? or resized?
  end

  def to_s
    title
  end

  private
  def generate_asset_token
    self.asset_token = SecureRandom.uuid
  end

  def set_default_title
    if title.blank? and original_filename.present?
      self.title = File.basename(original_filename, '.*').titleize
    end
  end
end
