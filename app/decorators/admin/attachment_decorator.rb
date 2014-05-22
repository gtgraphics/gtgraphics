class Admin::AttachmentDecorator < Admin::ApplicationDecorator
  decorates :attachment

  self.action_buttons -= [:show]

  def human_content_type
    default = I18n.translate('content_types.default', extension: File.extname(file_name).from(1).upcase, default: content_type)
    I18n.translate(content_type, scope: :content_types, default: default)
  end
end