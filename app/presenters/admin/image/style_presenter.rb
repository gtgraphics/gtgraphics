class Admin::Image::StylePresenter < Admin::ApplicationPresenter
  include FileAttachablePresenter

  presents :image_style
  delegate :image, to: :image_style

  self.action_buttons = [:edit, :move_up, :move_down, :destroy]

  def dimensions
     I18n.translate(:dimensions, width: width, height: height)
  end

  def pixels_count
    h.number_to_human(image.width * image.height) + " #{I18n.translate(:pixels)}"
  end

  # Routes

  def show_path
    h.admin_image_style_path(image, image_style)
  end

  def edit_path
    h.edit_admin_image_style_path(image, image_style)
  end


  def move_down_button(options = {})
    
  end

  def move_down_path
    h.move_down_admin_template_path(object)
  end

  def move_up_button(options = {})
    
  end

  def move_up_path
    h.move_up_admin_template_path(object)
  end
end