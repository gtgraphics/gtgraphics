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
#  transformed_width     :integer
#  transformed_height    :integer
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    class Variant < Image::Style
      # TODO Move Cropped, Resized, CropX, ..., ResizeHeight to a serialized data store

      validate :verify_either_cropped_or_resized

      before_save :set_dimensions
      around_save :reprocess_asset
      after_destroy :destroy_asset

      delegate :asset, :width, :height, to: :image, prefix: :original

      def asset_path
        original_asset.path(label)
      end

      def asset_url
        original_asset.url(label)
      end

      private
      def destroy_asset
        File.delete(asset_path)
      end

      def reprocess_asset
        changed = customization_options_changed?
        yield
        if changed
          # Check out this weird issue with reprocess!:
          # https://github.com/thoughtbot/paperclip/issues/866
          # But it should work for now here because it does not update the Image::Style::Variant model
          original_asset.reprocess!(label)
        end
      end

      def set_dimensions
        self.width = original_width
        self.height = original_height
      end

      def set_transformation_defaults
        self.cropped = true if cropped.nil?
        self.resized = false if resized.nil?
      end

      def verify_either_cropped_or_resized
        errors.add(:base, :invalid) unless cropped? or resized?
      end
    end      
  end
end
