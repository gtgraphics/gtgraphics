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
#  width              :integer
#  height             :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    include BatchTranslatable
    include ImageContainable

    belongs_to :image
    delegate :asset, to: :image, prefix: :original
     
    translates :name, fallbacks_for_empty_translations: true
   
    acts_as_image_containable url: '/system/images/:image_id/styles/:id/:style.:extension'

    validates :image_id, presence: true

    attr_accessor :crop_width, :crop_height, :crop_x, :crop_y
   
    Paperclip.interpolates :image_id do |attachment, style|
      attachment.instance.image_id
    end
  end
end
