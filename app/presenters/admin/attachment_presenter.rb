class Admin::AttachmentPresenter < Admin::ApplicationPresenter
  include FileAttachablePresenter

  presents :attachment

  self.action_buttons = [:show, :download, :convert_to_image, :edit, :destroy]

  def hits_count
    h.number_to_human super
  end

  # Buttons

  def convert_to_image_button(options = {})
    if attachment.image?
      button_options = {
        icon: :picture, icon_options: { outline: true }, method: :patch, 
        data: { confirm: I18n.translate('helpers.confirmations.convert', model: Attachment.model_name.human, other_model: Image.model_name.human(count: 2)) }
      }
      button_options[:caption] = I18n.translate('helpers.links.convert_to', model: Image.model_name.human)
      button :convert_to_image, default_button_options(options).deep_merge(options.reverse_merge(button_options))
    end
  end

  def download_button(options = {})
    button_options = { active: readable?, icon: :download, caption: :download }
    button :download, default_button_options(options).deep_merge(options.reverse_merge(button_options))
  end

  # Paths

  def show_path
    h.attachment_path(attachment.asset.filename, locale: nil, translations: nil)
  end

  def download_path
    h.download_attachment_path(attachment.asset.filename, locale: nil, translations: nil)
  end

  def convert_to_image_path
    h.convert_to_image_admin_attachment_path(attachment)
  end
end