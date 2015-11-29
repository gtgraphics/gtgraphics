module FileAttachablePresenter
  extend ActiveSupport::Concern

  included do
    alias_method :file, :object
  end

  def content_type
    extension = File.extname(original_filename).to_s.from(1)

    if file.content_type.blank? && extension.blank?
      I18n.translate('content_types.unknown')
    else
      file_type = I18n.translate(
        extension, scope: :content_types,
                   extension: extension.upcase,
                   default: I18n.translate('content_types.default')
      )
      I18n.translate(super, scope: :content_types, default: file_type)
    end
  end

  def file_size
    h.number_to_human_size(super)
  end
end
