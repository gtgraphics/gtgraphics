# == Schema Information
#
# Table name: album_images
#
#  id       :integer          not null, primary key
#  album_id :integer          not null
#  image_id :integer          not null
#  position :integer          default(0), not null
#

class Image::AlbumAssignment < ActiveRecord::Base
  self.table_name = 'album_images'

  belongs_to :album
  belongs_to :image

  acts_as_list
end
