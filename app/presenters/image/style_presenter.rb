class Image::StylePresenter < ApplicationPresenter
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
end
