module ContentTypeHelper
  def content_type(content_type)
    file_extension = File.extname(content_type.split('/').last).upcase
    default_translation = I18n.translate('content_types.default', extension: file_extension, default: content_type)
    I18n.translate(content_type, scope: :content_types, default: default_translation)
  end
end