class Admin::AttachmentPresenter < Admin::ApplicationPresenter
  include FileAttachablePresenter

  presents :attachment

  self.action_buttons = [:convert_to_image, :download, :edit, :destroy]

  def convert_to_image_button(options = {})
    if attachment.image?
      button_options = { icon: :picture, icon_options: { outline: true }, method: :patch }
      button_options[:caption] = I18n.translate('helpers.links.convert_to', model: Image.model_name.human)
      button :convert_to_image, default_button_options(options).deep_merge(options.reverse_merge(button_options))
    end
  end

  def convert_to_image_path
    h.convert_to_image_admin_attachment_path(attachment)
  end

  def download_button(options = {})
    button_options = { active: readable?, icon: :download, caption: :download }
    button :download, default_button_options(options).deep_merge(options.reverse_merge(button_options))
  end

  def download_path
    h.download_admin_attachment_path(attachment)
  end
end