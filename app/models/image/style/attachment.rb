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
    class Attachment < Image::Style
      include ImageContainable

      acts_as_image_containable url: '/system/images/:image_id/:style_label.:extension',
                                styles: { thumbnail: { geometry: '75x75#', format: :png } }

      validates_attachment :asset, presence: true, content_type: { content_type: ImageContainable::CONTENT_TYPES }

      delegate :path, :url, to: :asset, prefix: true

      def cropped?
        false
      end

      def resized?
        false
      end

      Paperclip.interpolates :image_id do |attachment, style|
        attachment.instance.image_id
      end

      Paperclip.interpolates :style_label do |attachment, style|
        if style == :original
          attachment.instance.label
        else
          "#{attachment.instance.label}_#{style}"
        end
      end
    end
  end
end
