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

    validates :title, presence: true
    validates :image_id, presence: true, strict: true

    default_scope -> { order(:position) }

    # before_save :set_customized_dimensions

    # delegate :asset_token, to: :image

    private
    def set_customized_dimensions
      if resized?
        self.width = resize_width
        self.height = resize_height
      elsif cropped?
        self.width = crop_width
        self.height = crop_height
      else
        self.width = original_width
        self.height = original_height
      end
    end
  end
end
