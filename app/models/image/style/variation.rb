# == Schema Information
#
# Table name: image_styles
#
#  id                    :integer          not null, primary key
#  image_id              :integer
#  created_at            :datetime
#  updated_at            :datetime
#  type                  :string(255)      not null
#  asset_file_name       :string(255)
#  asset_content_type    :string(255)
#  asset_file_size       :integer
#  asset_updated_at      :datetime
#  width                 :integer
#  height                :integer
#  customization_options :text
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    class Variation < Image::Style
      # TODO Move Cropped, Resized, CropX, ..., ResizeHeight to a serialized data store

      store :customization_options, accessors: [:cropped, :crop_x, :crop_y, :crop_width, :crop_height, :resized, :resize_width, :resize_height]

      with_options presence: true do |style|
        style.validates :crop_x, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :cropped?
        style.validates :crop_y, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :cropped?
        style.validates :crop_width, numericality: { only_integer: true, greater_than: 0 }, if: :cropped?
        style.validates :crop_height, numericality: { only_integer: true, greater_than: 0 }, if: :cropped?
        style.validates :resize_width, numericality: { only_integer: true, greater_than: 0 }, if: :resized?
        style.validates :resize_height, numericality: { only_integer: true, greater_than: 0 }, if: :resized?
      end

      after_initialize :set_defaults, if: :new_record?
      before_save :clear_crop_area, unless: :cropped?
      before_save :clear_resize_geometry, unless: :resized?
      before_save :set_dimensions
      after_save :reprocess_asset
      after_destroy :destroy_asset

      delegate :asset, :width, :height, to: :image, prefix: :original

      validate :validate_either_cropped_or_resized

      %w(crop_x crop_y crop_width crop_height resize_width resize_height).each do |method|
        class_eval %{
          def #{method}=(value)
            super(value.to_i)
          end
        }
      end

      def asset_path
        original_asset.path(label)
      end

      def asset_url
        original_asset.url(label)
      end

      def crop_geometry
        "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}"
      end

      def cropped
        !!super
      end
      alias_method :cropped?, :cropped

      def cropped=(cropped)
        super(cropped.try(:in?, ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES))
      end

      def dimensions
        ImageContainable::Dimensions.new(width, height)
      end

      def resize_geometry
        resize_width = self.resize_width || '100%'
        resize_height = self.resize_height || '100%'
        "#{resize_width}x#{resize_height}!"
      end

      def resized
        !!super
      end
      alias_method :resized?, :resized

      def resized=(resized)
        super(resized.try(:in?, ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES))
      end

      def transformations
        convert_options = String.new
        convert_options << " -crop #{crop_geometry} +repage" if cropped?
        convert_options << " -resize #{resize_geometry}" if resized?
        { geometry: '100%x100%', convert_options: convert_options }
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

      def set_defaults
        self.cropped = true
        self.resized = false
      end

      def set_dimensions
        if cropped?
          self.width = crop_width
          self.height = crop_height
        elsif resized?
          self.width = resize_width
          self.height = resize_height
        else
          self.width = image.width
          self.height = image.height
        end
      end

      def validate_either_cropped_or_resized
        errors.add(:base, :invalid) unless cropped? or resized?
      end
    end      
  end
end
