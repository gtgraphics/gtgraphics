# == Schema Information
#
# Table name: image_translations
#
#  id       :integer          not null, primary key
#  image_id :integer          not null
#  locale   :string(2)        not null
#  caption  :string(255)
#

class Image::Translation < ActiveRecord::Base
  include ::Translation
end
