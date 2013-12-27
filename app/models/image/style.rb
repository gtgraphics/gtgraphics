# == Schema Information
#
# Table name: image_styles
#
#  id                    :integer          not null, primary key
#  image_id              :integer
#  crop_width            :integer
#  crop_height           :integer
#  created_at            :datetime
#  updated_at            :datetime
#  crop_x                :integer
#  crop_y                :integer
#  resize_width          :integer
#  resize_height         :integer
#  preserve_aspect_ratio :boolean          default(TRUE)
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

    after_save :reprocess_asset

    delegate :asset, :width, :height, to: :image, prefix: :original
  
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

    def resized?
      resize_width.present? or resize_height.present?
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
    def reprocess_asset
      original_asset.reprocess!
    end
  end
end
