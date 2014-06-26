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
#  original_width        :integer
#  original_height       :integer
#  customization_options :text
#  width                 :integer
#  height                :integer
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    class Attachment < Image::Style
      include Image::AssetContainable

      acts_as_image_containable url: '/system/images/:image_id/:style_label.:extension',
                                styles: { transformed: { geometry: '100%x100%', processors: [:manual_cropper, :manual_resizer] },
                                          thumbnail: { geometry: '75x75#', format: :png, processors: [:manual_cropper, :manual_resizer] } },
                                default_style: :transformed

      after_validation :set_transformation_defaults, if: :asset_changed?
      after_validation :reset_transformed_dimensions, if: :asset_changed?
      around_save :reprocess_asset

      delegate :path, :url, to: :asset, prefix: true
      alias_method :original_asset, :asset

      Paperclip.interpolates :image_id do |attachment, style|
        attachment.instance.image_id
      end

      Paperclip.interpolates :style_label do |attachment, style|
        if style == :transformed
          attachment.instance.label
        else
          "#{attachment.instance.label}_#{style}"
        end
      end

      private
      def reprocess_asset
        changed = customization_options_changed?
        yield
        if changed
          # This is a Paperclip hack to force reprocessing of the asset:
          # https://github.com/thoughtbot/paperclip/issues/866
          asset.assign(asset)
          asset.save
          update_column(:asset_updated_at, DateTime.now)
        end
      end

      def set_transformation_defaults
        self.cropped = false if cropped.nil?
        self.resized = false if resized.nil?
      end

      def reset_transformed_dimensions
        self.transformed_width = width
        self.transformed_height = height
      end
    end
  end
end
