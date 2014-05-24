module ImageCroppable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_image_croppable
      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    included do
      with_options allow_blank: true, if: :cropped? do |croppable|
        croppable.validates :crop_x, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
        croppable.validates :crop_y, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
        croppable.validates :crop_width, numericality: { only_integer: true, greater_than: 0 }
        croppable.validates :crop_height, numericality: { only_integer: true, greater_than: 0 }
      end

      validate :verify_crop_dimensions_consistency, on: :update, if: :cropped?

      # before_validation :clear_crop_area, if: :asset_changed?
      before_save :clear_crop_area, unless: :cropped?

      store_accessor :customization_options, :cropped, :crop_x, :crop_y, :crop_width, :crop_height
      alias_method :cropped?, :cropped

      %w(crop_x crop_y crop_width crop_height).each do |method|
        class_eval %{
          def #{method}=(value)
            super(value.try(:to_i))
          end
        }
      end

      class_eval %{
        def cropped=(cropped)
          super(cropped.to_b)
        end
      }
    end

    def crop_dimensions
      ImageDimensions.new(crop_width, crop_height) if cropped?
    end

    def crop_geometry
      "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}" if cropped?
    end

    protected
    def clear_crop_area
      self.crop_x = nil
      self.crop_y = nil
      self.crop_width = nil
      self.crop_height = nil
    end

    private
    def verify_crop_dimensions_consistency
      if crop_x + crop_width > original_width
        errors.add(:crop_x, :invalid)
        errors.add(:crop_width, :invalid)
      end
      if crop_y + crop_height > original_height
        errors.add(:crop_y, :invalid)
        errors.add(:crop_height, :invalid)
      end
    end  
  end
end