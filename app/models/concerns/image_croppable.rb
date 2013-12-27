module ImageCroppable
  extend ActiveSupport::Concern

  included do
    with_options allow_blank: true do |croppable|
      croppable.validates :crop_x, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      croppable.validates :crop_y, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      croppable.validates :crop_width, numericality: { only_integer: true, greater_than: 0 }
      croppable.validates :crop_height, numericality: { only_integer: true, greater_than: 0 }
    end

    validate :validate_crop_dimensions_consistency, if: :cropped?

    before_validation :clear_crop_area, if: :asset_changed?
  end

  def cropped?
    crop_x.present? and crop_y.present? and crop_width.present? and crop_height.present?
  end

  private
  def clear_crop_area
    self.crop_x = nil
    self.crop_y = nil
    self.crop_width = nil
    self.crop_height = nil
  end

  def validate_crop_dimensions_consistency
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