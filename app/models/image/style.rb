# == Schema Information
#
# Table name: image_styles
#
#  id                    :integer          not null, primary key
#  image_id              :integer
#  created_at            :datetime
#  updated_at            :datetime
#  asset                 :string
#  content_type          :string
#  file_size             :integer
#  asset_updated_at      :datetime
#  original_width        :integer
#  original_height       :integer
#  customization_options :text
#  width                 :integer
#  height                :integer
#  position              :integer          not null
#  original_filename     :string
#  asset_token           :string           not null
#  downloads_count       :integer          default(0), not null
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    include Image::Attachable
    include Image::Croppable
    include Image::Resizable
    include Image::ExifAnalyzable

    include Downloadable
    include PersistenceContextTrackable
    include TitleSearchable
    include Translatable

    belongs_to :image, inverse_of: :styles, touch: true
    delegate :author, to: :image

    after_save :write_copyright!, if: :asset_changed?

    translates :title, fallbacks_for_empty_translations: true

    acts_as_list scope: :image_id

    default_scope -> { order(:position) }

    has_image
    acts_as_croppable
    acts_as_resizable

    validates :image_id, presence: true, strict: true

    def virtual_filename
      I18n.with_locale(I18n.default_locale) do
        if title.present?
          super
        else
          image.title.parameterize.underscore +
            File.extname(original_filename).downcase
        end
      end
    end

    def write_copyright!
      with_metadata :public do |metadata|
        metadata.copyright = image.copyright_note
        metadata.save!
      end
    rescue MiniExiftool::Error => error
      logger.error "Error writing Exif data: #{error.message}"
    end
  end
end

require_dependency 'image'
