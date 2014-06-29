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
      validates :asset, presence: true

      before_validation :set_original_filename_content_type_and_file_size, if: :asset_changed?
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
    def set_original_filename_content_type_and_file_size
      if asset.file.respond_to?(:original_filename)
        self.original_filename = asset.file.original_filename 
      end
      self.content_type = asset.file.content_type
      self.file_size = asset.file.size
    end
  end
end