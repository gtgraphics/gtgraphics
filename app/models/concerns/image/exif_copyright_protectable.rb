class Image < ActiveRecord::Base
  # This module is included in Image and Image::Style to ensure that a indivual
  # copyright note is assigned to each uploaded Image or created Image::Style.
  module ExifCopyrightProtectable
    extend ActiveSupport::Concern

    included do
      include Image::ExifAnalyzable

      before_save if: :write_exif_copyright? do
        # Try writing copyright metadata, but don't complain if it didn't work
        write_exif_copyright!
        true
      end
    end

    def write_exif_copyright!
      return false if exif.copyright.present?
      year = (exif.date_time_created || exif.date_time).year rescue Date.today.year
      exif.copyright = "GT Graphics #{year}, #{author.name} (#{author.email})"
      exif.save!
      true
    rescue MiniExiftool::Error
      false
    end

    private

    def write_exif_copyright?
      exif_capable? && (asset_changed? || author_id_changed?)
    end
  end
end
