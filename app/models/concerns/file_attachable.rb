module FileAttachable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_attachment(uploader_class = nil)
      uploader_class ||= "#{self.name}Uploader".constantize
      mount_uploader :asset, uploader_class
      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    included do
      after_initialize :generate_asset_token

      with_options if: [:asset?, :asset_changed?] do |opts|
        opts.before_validation :set_original_filename
        opts.before_validation :set_content_type
        opts.before_validation :set_file_size
        opts.before_save :set_asset_updated_at
      end
    end

    def mime_type
      Mime::Type.parse(content_type).first
    end

    def recreate_assets!
      asset.recreate_versions!
      set_content_type
      set_file_size
      set_asset_updated_at
      save!
    end

    def virtual_filename
      I18n.with_locale(I18n.default_locale) do
        if title.present?
          title.parameterize.underscore +
            File.extname(original_filename).downcase
        else
          original_filename
        end
      end
    end

    private

    def generate_asset_token
      return if !respond_to?(:asset_token) || asset_token?
      original_filename = asset.file.try(:original_filename)
      token = RandomString.generate
      if original_filename
        name = File.basename(original_filename, '.*')
               .slice(0...40).parameterize.dasherize
        self.asset_token = "#{name}-#{token}"
      else
        self.asset_token = token
      end
    end

    def set_original_filename
      if asset.file.respond_to?(:original_filename) && original_filename.blank?
        self.original_filename = asset.file.original_filename
      end
    end

    def set_content_type
      self.content_type = asset.file.content_type
    end

    def set_file_size
      self.file_size = asset.file.size
    end

    def set_asset_updated_at
      self.asset_updated_at = DateTime.now
    end
  end
end
