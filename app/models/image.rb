# == Schema Information
#
# Table name: images
#
#  id                    :integer          not null, primary key
#  asset                 :string(255)
#  content_type          :string(255)
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
#  original_filename     :string(255)
#  asset_token           :string(255)      not null
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

  has_many :styles, class_name: 'Image::Style', inverse_of: :image, dependent: :destroy
  has_many :image_pages, class_name: 'Page::Image', inverse_of: :image, dependent: :destroy
  has_many :pages, through: :image_pages

  has_image
  has_owner :author, default_owner_to_current_user: false
  
  translates :title, :description, fallbacks_for_empty_translations: true
  sanitizes :title, with: :squish

  validates :asset, presence: true
  validates :title, presence: true

  # before_save :set_predefined_style_dimensions
  before_validation :set_default_title, on: :create

  acts_as_sortable do |by|
    by.title(default: true) { |column, dir| Image::Translation.arel_table[column].send(dir.to_sym) }
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.created_at
  end

  def self.search(query)
    if query.present?
      terms = query.to_s.split.uniq.map { |term| "%#{term}%" }
      ransack(translations_title_matches_any: terms).result.uniq
    else
      all
    end
  end

  def dominant_colors
    @dominant_colors ||= Miro::DominantColors.new(asset.custom.path)
  end

  def manipulated?
    cropped? or resized? or false
  end

  def to_attachment(version = :custom)
    Attachment.new do |attachment|
      attachment.asset = asset.versions.fetch(version.to_sym) do 
        raise ArgumentError, "unknown version: #{version}"
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

  private
  def set_default_title
    if title.blank? and original_filename.present?
      self.title = File.basename(original_filename, '.*').titleize
    end
  end
end
