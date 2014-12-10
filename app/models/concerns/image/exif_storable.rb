class Image < ActiveRecord::Base
  module ExifStorable
    extend ActiveSupport::Concern

    EXIF_CAPABLE_CONTENT_TYPES = [Mime::JPEG].freeze

    included do
      store :exif_data

      before_save :write_copyright, if: -> { exif_capable? and (asset_changed? or author_id_changed?) }
      before_save :cache_exif_data, if: [:exif_capable?, :asset_changed?]
    end

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

    # Accessors for commonly accessed data

    def camera
      exif_data['Model']
    end

    def software
      exif_data['Software']
    end

    def taken_at
      (exif_data['DateTimeOriginal'] || exif_data['DateTime']).try(:to_datetime)
    end
    
    private
    def cache_exif_data
      self.exif_data = exif.to_hash
    end

    def write_copyright
      year = taken_at.try(:year) || Date.today.year
      exif.copyright = [author.name, author.email, year].join(', ')
      exif.save!
    end
  end
end