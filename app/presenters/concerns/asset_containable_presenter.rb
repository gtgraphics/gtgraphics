module AssetContainablePresenter
  def content_type
    file_extension = File.extname(file_name).from(1).upcase
    default_translation = I18n.translate('content_types.default', extension: file_extension, default: super)
    I18n.translate(super, scope: :content_types, default: default_translation)
  end

  def file_size
    h.number_to_human_size(super)
  end
end