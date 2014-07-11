class Admin::Image::StylePresenter < Admin::ApplicationPresenter
  include FileAttachablePresenter

  presents :image_style

  def dimensions
     I18n.translate(:dimensions, width: width, height: height)
  end

  def pixels_count
    h.number_to_human(image.width * image.height) + " #{I18n.translate(:pixels)}"
  end
end