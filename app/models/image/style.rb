# == Schema Information
#
# Table name: image_styles
#
#  id            :integer          not null, primary key
#  image_id      :integer
#  cropped       :boolean          default(TRUE), not null
#  crop_width    :integer
#  crop_height   :integer
#  crop_x        :integer
#  crop_y        :integer
#  resized       :boolean          default(FALSE), not null
#  resize_width  :integer
#  resize_height :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    belongs_to :image, inverse_of: :custom_styles
    
    validates :image_id, presence: true
    with_options allow_blank: true do |style|
      style.validates :crop_x, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      style.validates :crop_y, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      style.validates :crop_width, numericality: { only_integer: true, greater_than: 0 }
      style.validates :crop_height, numericality: { only_integer: true, greater_than: 0 }
      style.validates :resize_width, numericality: { only_integer: true, greater_than: 0 }
      style.validates :resize_height, numericality: { only_integer: true, greater_than: 0 }
    end

    before_save :clear_crop_area, unless: :cropped?
    before_save :clear_resize_geometry, unless: :resized?
    after_save :reprocess_asset
    after_destroy :destroy_asset

    delegate :asset, :width, :height, to: :image, prefix: :original

    validate :validate_either_cropped_or_resized
  
    def asset_path
      original_asset.path(label)
    end

    def asset_url
      original_asset.url(label)
    end

    def cropped?
      crop_x.present? and crop_y.present? and crop_width.present? and crop_height.present?
    end

    def crop_geometry
      "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}"
    end

    def dimensions
      ImageContainable::Dimensions.new(width, height)
    end

    def height
      resize_height || crop_height
    end

    def label
      "custom_#{id}"
    end

    def resize_geometry
      resize_width = self.resize_width || '100%'
      resize_height = self.resize_height || '100%'
      "#{resize_width}x#{resize_height}!"
    end

    def transformations
      convert_options = String.new
      convert_options << " -crop #{crop_geometry} +repage" if cropped?
      convert_options << " -resize #{resize_geometry}" if resized?
      { geometry: '100%x100%', convert_options: convert_options }
    end
    
    def width
      resize_width || crop_width
    end

    private
    def clear_crop_area
      self.crop_x = nil
      self.crop_y = nil
      self.crop_width = nil
      self.crop_height = nil
    end

    def clear_resize_geometry
      self.resize_width = nil
      self.resize_height = nil
    end

    def destroy_asset
      File.delete(asset_path)
    end

    def reprocess_asset
      original_asset.reprocess!(label)
    end

    def validate_either_cropped_or_resized
      errors.add(:base, :invalid) unless cropped? or resized?
    end
  end
end
