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
    TYPES = %w(
      Image::Style::Attachment
      Image::Style::Variation
    ).freeze

    belongs_to :image, inverse_of: :custom_styles

    validates :image_id, presence: true

    TYPES.each do |type|
      scope type.demodulize.underscore.pluralize, -> { where(type: type) }

      class_eval %{
        def #{type.demodulize.underscore}?
          type == '#{type}'
        end
      }
    end

    def label
      "custom_#{id}"
    end
  end
end
