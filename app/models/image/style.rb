# == Schema Information
#
# Table name: image_styles
#
#  id                 :integer          not null, primary key
#  image_id           :integer
#  asset_file_name    :string(255)
#  asset_content_type :string(255)
#  asset_file_size    :integer
#  asset_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  crop_x             :integer
#  crop_y             :integer
#  crop_width         :integer
#  crop_height        :integer
#  resize_width       :integer
#  resize_height      :integer
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    include ImageContainable
    include ImageCroppable
    include ImageResizable

    acts_as_image_containable styles: ->(attachment) { attachment.instance.styles }, url: '/system/images/:image_id/styles/:id/:style.:extension'

    belongs_to :image
    
    validates :image_id, presence: true

    delegate :asset, :width, :height, to: :image, prefix: :original
  
    class << self
      def content_types
        ImageContainable::CONTENT_TYPES
      end
    end

    def label
      "custom_#{crop_width}x#{crop_height}"
    end


    def to_h
      { geometry: '100%x100%' } # make a paperclip style hash out of it
    end

    Paperclip.interpolates :image_id do |attachment, style|
      attachment.instance.image_id
    end
  end
end
