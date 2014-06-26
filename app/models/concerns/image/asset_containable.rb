class Image < ActiveRecord::Base
  module AssetContainable
    extend ActiveSupport::Concern

    MIME_TYPES = [Mime::JPEG, Mime::GIF, Mime::PNG].freeze

    module ClassMethods
      def has_image(options = {})
        include ::AssetContainable
        has_asset(options)
        include Extensions
      end
    end

    module Extensions
      extend ActiveSupport::Concern

      included do
        before_save :set_original_dimensions, if: :asset_changed?

        delegate :aspect_ratio, :pixels, to: :dimensions

        store :customization_options
      end

      module ClassMethods
        def permitted_mime_types
          MIME_TYPES
        end
      end

      def format
        mime_type.to_sym
      end

      def mime_type
        self.class.permitted_mime_types.find { |content_type| content_type == self.content_type }
      end

      private
      def set_original_dimensions
        dimensions = Paperclip::Geometry.from_file(asset.queued_for_write[:original].path)
        self.width = dimensions.width.to_i
        self.height = dimensions.height.to_i
      end
    end
  end
end