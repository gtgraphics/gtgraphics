module ImageResizable
  extend ActiveSupport::Concern

  included do
    with_options numericality: { only_integer: true }, allow_blank: true do |resizable|
      resizable.validates :resize_width
      resizable.validates :resize_height
    end

    before_validation :clear_resize_dimensions, if: :asset_changed?
  end

  def resized?
    resize_width.present? and resize_height.present?
  end

  private
  def clear_resize_dimensions
    self.resize_width = nil
    self.resize_height = nil
  end
end