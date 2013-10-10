# == Schema Information
#
# Table name: image_translations
#
#  id         :integer          not null, primary key
#  image_id   :integer          not null
#  locale     :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  caption    :text
#

class Image::Translation < ActiveRecord::Base
  include ::Translation
end
