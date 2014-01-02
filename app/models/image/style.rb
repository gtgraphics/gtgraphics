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
    TYPES = %w(
      Image::Style::Variation
      Image::Style::Attachment
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
