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
    include Image::AssetContainable
    include Image::Croppable
    include Image::Resizable
    include PersistenceContextTrackable

    STYLES = {
      custom: { geometry: '100%x100%', processors: [:manual_cropper, :manual_resizer] },
      thumbnail: { geometry: '75x75#', format: :png, processors: [:manual_cropper, :manual_resizer] }
    }.freeze

    belongs_to :image, inverse_of: :custom_styles

    translates :title, fallbacks_for_empty_translations: true

    has_image url: '/system/images/:image_id/styles/:id/:style.:extension',
              styles: STYLES,
              default_style: :custom

    validates :image_id, presence: true, strict: true

    before_save :set_customized_dimensions

    TYPES.each do |type|
      scope type.demodulize.underscore.pluralize, -> { where(type: type) }

      class_eval <<-RUBY
        def #{type.demodulize.underscore}?
          type == '#{type}'
        end
      RUBY
    end

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

    Paperclip.interpolates :image_id do |attachment, style|
      attachment.instance.image_id
    end
  end
end
