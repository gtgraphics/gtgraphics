# == Schema Information
#
# Table name: shouts
#
#  id         :integer          not null, primary key
#  nickname   :string
#  message    :text
#  x          :integer          not null
#  y          :integer          not null
#  ip         :string
#  user_agent :string
#  created_at :datetime
#  star_type  :integer
#

class Shout < ActiveRecord::Base
end
