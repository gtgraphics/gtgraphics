class Admin::Image::StylePresenter < Admin::ApplicationPresenter
  include DownloadCountablePresenter
  include FileAttachablePresenter
  include Admin::MovableResourcePresenter
  include Admin::Image::CustomizablePresenter

  presents :image_style
  delegate :image, to: :image_style

  self.action_buttons = [:edit, :customize, :move_up, :move_down, :destroy]

  def title
    super.presence || dimensions
  end

  def dimensions
     I18n.translate(:dimensions, width: width, height: height)
  end

  def pixels_count
    h.number_to_human(image.width * image.height) + " #{I18n.translate(:pixels)}"
  end

  def downloads_count
    h.number_with_delimiter(super)
  end

  # Routes

  def show_path
    h.admin_image_style_path(image, image_style)
  end

  def edit_path
    h.edit_admin_image_style_path(image, image_style)
  end

  def customize_path
    h.customize_admin_image_style_path(image, image_style)
  end

  def move_down_path
    h.move_down_admin_image_style_path(image, image_style)
  end

  def move_up_path
    h.move_up_admin_image_style_path(image, image_style)
  end
end
