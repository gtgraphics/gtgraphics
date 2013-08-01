# == Schema Information
#
# Table name: albums
#
#  id         :integer          not null, primary key
#  slug       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Album < ActiveRecord::Base
  translates :title

  has_many :image_assignments, class_name: 'Image::AlbumAssignment', dependent: :destroy
  has_many :images, through: :image_assignments

  validates :title, presence: true, uniqueness: true
end
