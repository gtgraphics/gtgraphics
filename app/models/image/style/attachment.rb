# == Schema Information
#
# Table name: image_styles
#
#  id                 :integer          not null, primary key
#  image_id           :integer
#  crop_width         :integer
#  crop_height        :integer
#  created_at         :datetime
#  updated_at         :datetime
#  crop_x             :integer
#  crop_y             :integer
#  resize_width       :integer
#  resize_height      :integer
#  cropped            :boolean          default(TRUE)
#  resized            :boolean          default(FALSE)
#  type               :string(255)      not null
#  asset_file_name    :string(255)
#  asset_content_type :string(255)
#  asset_file_size    :integer
#  asset_updated_at   :datetime
#  width              :integer
#  height             :integer
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    class Attachment < Image::Style
      include ImageContainable

      acts_as_image_containable url: '/system/images/:image_id/:style_label.:extension'

      validates_attachment :asset, content_type: { content_type: ImageContainable::CONTENT_TYPES }

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
        attachment.instance.label
      end
    end
  end
end
