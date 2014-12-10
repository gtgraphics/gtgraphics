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

    def exif
      @exif ||= begin
        raise 'Document is not capable to contain Exif metadata' unless exif_capable?
        MiniExiftool.new(asset.path, replace_invalid_chars: '')
      end
    end

    def exif_capable?
      content_type.in?(self.class.exif_capable_content_types)
    end

    def write_exif_copyright!
      year = (exif[:date_time] || exif[:date_time] || Date.today).year
      exif.copyright = "GT Graphics #{year}, #{author.name} (#{author.email})"
      exif.save!
      true
    end
  end
end