class Image::StylePresenter < ApplicationPresenter
  include FileAttachablePresenter

  presents :style

  def title
    super.presence || dimensions
  end

  def dimensions
    I18n.translate(:dimensions, width: width, height: height)
  end

  def pixels_count
    h.capture do
      h.concat h.number_to_human(image.width * image.height)
      h.concat ' '
      h.concat I18n.translate(:pixels)
    end
  end

  # Aspect Ratio

  KNOWN_ASPECT_RATIOS = %w(16:10 16:9 4:3 3:2).freeze

  def self.known_aspect_ratios
    KNOWN_ASPECT_RATIOS.each_with_object({}) do |caption, ratios|
      ratio = Rational(*caption.split(':', 2))
      ratios[ratio] = caption
    end
  end

  def aspect_ratio
    caption = self.class.known_aspect_ratios[style.aspect_ratio]
    return I18n.translate('aspect_ratios.others') if caption.nil?
    I18n.translate(caption, scope: :aspect_ratios, default: caption)
  end
end
