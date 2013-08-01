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
end
