module FileAttachablePresenter
  extend ActiveSupport::Concern

  included do
    alias_method :file, :object
  end

  def content_type
    if file.content_type.blank? && file.file_extension.blank?
      I18n.translate('content_types.unknown')
    else
      file_type = I18n.translate(
        file.file_extension, scope: :content_types,
                             extension: file.file_extension.upcase,
                             default: I18n.translate('content_types.default')
      )
      return file_type if file.content_type.blank?
      I18n.translate(file.content_type, scope: :content_types,
                                        default: file_type)
    end
  end

  def file_size
    h.number_to_human_size file.file_size, strip_insignificant_zeros: false,
                                           precision: 3
  end
end
