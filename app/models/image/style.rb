# == Schema Information
#
# Table name: image_styles
#
#  id                    :integer          not null, primary key
#  image_id              :integer
#  created_at            :datetime
#  updated_at            :datetime
#  asset                 :string(255)
#  content_type          :string(255)
#  file_size             :integer
#  asset_updated_at      :datetime
#  original_width        :integer
#  original_height       :integer
#  customization_options :text
#  width                 :integer
#  height                :integer
#  position              :integer          not null
#  original_filename     :string(255)
#  asset_token           :string(255)
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    include Image::Attachable
    include Image::Croppable
    include Image::Resizable
    include PersistenceContextTrackable
    include Sortable
    include Translatable

    belongs_to :image, inverse_of: :styles

    translates :title, fallbacks_for_empty_translations: true

    acts_as_list scope: :image_id

    acts_as_sortable do |by|
      by.title(default: true) { |column, dir| Image::Style::Translation.arel_table[column].send(dir.to_sym) }
      by.dimensions { |column, dir| "(#{table_name}.width * #{table_name}.height) #{dir}" }
    end

    has_image

    validates :image_id, presence: true, strict: true

    before_validation :set_default_title, on: :create

    default_scope -> { order(:position) }

    def virtual_filename
      I18n.with_locale(I18n.default_locale) do
        if title.present?
          super
        else
          image.title.parameterize('_') + File.extname(original_filename).downcase
        end
      end
    end

    private
    def set_default_title
      if title.blank? and original_filename.present?
        self.title = File.basename(original_filename, '.*').titleize
      end
    end
  end
end
