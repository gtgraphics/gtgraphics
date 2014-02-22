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
    include ImageCroppable
    include ImageResizable
    include PersistenceContextTrackable

    TYPES = %w(
      Image::Style::Variant
      Image::Style::Attachment
    ).freeze

    store :customization_options

    belongs_to :image, inverse_of: :custom_styles

    after_initialize :set_transformation_defaults, if: :new_record?
    before_save :set_transformed_dimensions

    validates :image, presence: true

    default_scope -> { order("#{table_name}.transformed_width * #{table_name}.transformed_height") }

    TYPES.each do |type|
      scope type.demodulize.underscore.pluralize, -> { where(type: type) }

      class_eval %{
        def #{type.demodulize.underscore}?
          type == '#{type}'
        end
      }
    end

    def dimensions
      ImageDimensions.new(width, height)
    end

    def label
      "custom_#{id}"
    end

    def transformations
      convert_options = String.new
      convert_options << " -crop #{crop_geometry} +repage" if cropped?
      convert_options << " -resize #{resize_geometry}" if resized?
      { geometry: '100%x100%', convert_options: convert_options }
    end

    def transformed_dimensions
      ImageDimensions.new(transformed_width, transformed_height)
    end

    protected
    def set_transformation_defaults
    end

    private
    def set_transformed_dimensions
      if resized?
        self.transformed_width = resize_width
        self.transformed_height = resize_height
      elsif cropped?
        self.transformed_width = crop_width
        self.transformed_height = crop_height
      else
        self.transformed_width = original_width
        self.transformed_height = original_height
      end
    end
  end
end
