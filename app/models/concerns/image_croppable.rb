module ImageCroppable
  extend ActiveSupport::Concern

  included do
    with_options numericality: { only_integer: true }, allow_blank: true do |croppable|
      croppable.validates :crop_x
      croppable.validates :crop_y
      croppable.validates :crop_width
      croppable.validates :crop_height
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
    if crop_x + crop_width > width
      errors.add(:crop_x, :invalid)
      errors.add(:crop_width, :invalid)
    end
    if crop_y + crop_height > height
      errors.add(:crop_y, :invalid)
      errors.add(:crop_height, :invalid)
    end
  end  
end