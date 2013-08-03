# == Schema Information
#
# Table name: album_images
#
#  id       :integer          not null, primary key
#  album_id :integer          not null
#  image_id :integer          not null
#  position :integer          default(0), not null
#

class Album::ImageAssignment < ActiveRecord::Base
  self.table_name = 'album_images'

  belongs_to :album, counter_cache: :images_count
  belongs_to :image

  default_scope -> { order(:position) }

  acts_as_list scope: :album_id
end
