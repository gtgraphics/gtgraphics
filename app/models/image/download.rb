# == Schema Information
#
# Table name: image_downloads
#
#  id            :integer          not null, primary key
#  image_id      :integer
#  attachment_id :integer
#  position      :integer          not null
#

class Image < ActiveRecord::Base
  class Download < ActiveRecord::Base
    acts_as_list scope: :image_id

    belongs_to :image, required: true
    belongs_to :attachment, required: true

    default_scope -> { order(:position) }

    delegate :title, :original_filename, to: :attachment
  end
end
