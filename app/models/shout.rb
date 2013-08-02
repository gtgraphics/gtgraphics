# == Schema Information
#
# Table name: shouts
#
#  id         :integer          not null, primary key
#  nickname   :string(255)
#  message    :text
#  x          :integer          not null
#  y          :integer          not null
#  ip         :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Shout < ActiveRecord::Base
  COORDINATES_PADDING = 10

  validate :check_coordinates_uniqueness

  def coordinates
    [x, y]
  end

  def x_padding
    (x-COORDINATES_PADDING)..(x+COORDINATES_PADDING)
  end

  def y_padding
    (y-COORDINATES_PADDING)..(y+COORDINATES_PADDING)
  end

  private
  def check_coordinates_uniqueness
    errors.add(:taken) if exists?(x: x_padding, y: y_padding)
  end
end
