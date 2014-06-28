# == Schema Information
#
# Table name: image_styles
#
#  id                    :integer          not null, primary key
#  image_id              :integer
#  created_at            :datetime
#  updated_at            :datetime
#  type                  :string(255)      not null
#  asset                 :string(255)
#  content_type          :string(255)
#  file_size             :integer
#  asset_updated_at      :datetime
#  original_width        :integer
#  original_height       :integer
#  customization_options :text
#  width                 :integer
#  height                :integer
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    include Image::Attachable
    include Image::Croppable
    include Image::Resizable
    include PersistenceContextTrackable

    belongs_to :image, inverse_of: :custom_styles

    translates :title, fallbacks_for_empty_translations: true

    has_image

    validates :image_id, presence: true, strict: true

    before_save :set_customized_dimensions

    delegate :asset_token, to: :image

    private
    def set_customized_dimensions
      if resized?
        self.width = resize_width
        self.height = resize_height
      elsif cropped?
        self.width = crop_width
        self.height = crop_height
      else
        self.width = original_width
        self.height = original_height
      end
    end
  end
end
