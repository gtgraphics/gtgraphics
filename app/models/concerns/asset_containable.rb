module AssetContainable
  extend ActiveSupport::Concern

  included do
    alias_attribute :file_name, :asset_file_name
    alias_attribute :content_type, :asset_content_type
    alias_attribute :file_size, :asset_file_size    
  end
 
  def human_content_type(locale = I18n.locale)
    I18n.translate(content_type, scope: :content_types, locale: locale, default: I18n.translate('content_types.default', extension: File.extname(file_name).from(1).upcase, locale: locale, default: content_type))
  end

  def virtual_file_name(locale = I18n.locale)
    title(locale).parameterize('_') + File.extname(file_name).downcase
  end
end