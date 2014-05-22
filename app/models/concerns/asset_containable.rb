module AssetContainable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_asset_containable(options = {})
      has_attached_file :asset, options
      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    included do
      alias_attribute :file_name, :asset_file_name
      alias_attribute :content_type, :asset_content_type
      alias_attribute :file_size, :asset_file_size    
    end

    def asset_changed?
      !asset.queued_for_write[:original].nil?
    end

    def virtual_file_name
      I18n.with_locale(I18n.default_locale) do
        title.parameterize.underscore + File.extname(file_name).downcase
      end
    end
  end
end