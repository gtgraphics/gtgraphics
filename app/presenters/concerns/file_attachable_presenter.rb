module FileAttachablePresenter
  def content_type
    file_extension = File.extname(original_filename).from(1).upcase
    return I18n.translate('content_types.unknown') if object.content_type.blank?
    default_translation = I18n.translate('content_types.default',
                                         extension: file_extension,
                                         default: object.content_type).presence
    I18n.translate(object.content_type, scope: :content_types,
                                        default: default_translation)
  end

  def file_size
    h.number_to_human_size(super)
  end
end
