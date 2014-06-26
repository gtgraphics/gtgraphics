# TODO Replace with Carrierwave

module AssetContainable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_asset(options = {})
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

      validates_attachment :asset, presence: true
      validate :verify_asset_content_type
    end

    module ClassMethods
      def permitted_content_types
        permitted_mime_types.map(&:to_s)
      end

      def permitted_mime_types
        []
      end
    end

    def asset_changed?
      !asset.queued_for_write[:original].nil?
    end

    def mime_type
      Mime::Type.parse(content_type).first
    end

    def virtual_file_name
      I18n.with_locale(I18n.default_locale) do
        title.parameterize.underscore + File.extname(file_name).downcase
      end
    end

    private
    def verify_asset_content_type
      unless self.class.permitted_content_types.include?(asset_content_type)
        types = self.class.permitted_content_types.join(', ')
        errors.add :asset_content_type, :invalid, types: types
        errors.add :asset, :invalid

        if record.errors.include? attribute
          record.errors[attribute].each do |error|
            record.errors.add base_attribute, error
          end
        end
      end
    end
  end
end