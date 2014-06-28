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
        # before_save :set_original_dimensions, if: :asset_changed?

        store :customization_options

        validates :content_type, presence: true,
                                 inclusion: { in: ->(attachable) { attachable.class.permitted_content_types }, allow_blank: true }
      end

      module ClassMethods
        def permitted_content_types
          permitted_mime_types.map(&:to_s).freeze
        end

        def permitted_mime_types
          MIME_TYPES
        end
      end

      def format
        mime_type.to_sym
      end

      def mime_type
        self.class.permitted_mime_types.find do |content_type|
          content_type == self.content_type
        end
      end

      private
      def set_original_dimensions
        # dimensions = Paperclip::Geometry.from_file(asset.queued_for_write[:original].path)
        # self.width = dimensions.width.to_i
        # self.height = dimensions.height.to_i
      end
    end
  end
end