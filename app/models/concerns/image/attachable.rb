class Image < ActiveRecord::Base
  module Attachable
    extend ActiveSupport::Concern

    MIME_TYPES = [Mime::JPEG, Mime::GIF, Mime::PNG].freeze

    module ClassMethods
      def has_image(uploader_class = nil)
        include FileAttachable
        has_attachment(uploader_class)
        include Extensions
      end
    end

    module Extensions
      extend ActiveSupport::Concern

      included do
        store :customization_options

        validates :content_type, presence: true,
                                 inclusion: { in: ->(attachable) { attachable.class.permitted_content_types }, allow_blank: true }

        before_create :set_original_dimensions
        before_save :set_geometry, if: :asset_changed?
      end

      module ClassMethods
        def permitted_content_types
          permitted_mime_types.map(&:to_s).freeze
        end

        def permitted_mime_types
          MIME_TYPES
        end
      end

      def recreate_assets!
        asset.recreate_versions!
        set_content_type
        set_file_size
        set_geometry
        set_asset_updated_at
        save!
      end

      def format
        mime_type.to_sym
      end

      def mime_type
        self.class.permitted_mime_types.find do |content_type|
          content_type == self.content_type
        end
      end

      protected
      def set_content_type
        self.content_type = asset.custom.file.content_type
      end

      def set_file_size
        self.file_size = asset.custom.file.size
      end

      def set_geometry
        custom_img = MiniMagick::Image.open(asset.custom.path)
        self.width = custom_img[:width]
        self.height = custom_img[:height]
      end

      private
      def set_original_dimensions
        original_img = MiniMagick::Image.open(asset.path)
        self.original_width = original_img[:width]
        self.original_height = original_img[:height]
      end
    end
  end
end