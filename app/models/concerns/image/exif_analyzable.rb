class Image < ActiveRecord::Base
  module ExifAnalyzable
    extend ActiveSupport::Concern

    EXIF_CAPABLE_CONTENT_TYPES = [Mime::JPEG].freeze

    module ClassMethods
      def exif_capable_content_types
        exif_capable_mime_types.map(&:to_s)
      end

      def exif_capable_mime_types
        EXIF_CAPABLE_CONTENT_TYPES
      end
    end

    def metadata(version = nil)
      data = {}
      with_metadata(version) do |metadata|
        data = metadata.to_hash
      end
      data
    end

    def with_metadata(version = nil)
      if version.nil?
        path = asset.path
      else
        path = asset.versions.fetch(version) do
          fail ArgumentError, "Invalid version: #{version}"
        end.path
      end
      metadata = MiniExiftool.new(path, replace_invalid_chars: '')
      yield(metadata)
    end

    def exif_capable?
      content_type.in?(self.class.exif_capable_content_types)
    end
  end
end
