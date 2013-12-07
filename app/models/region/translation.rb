# == Schema Information
#
# Table name: region_translations
#
#  id         :integer          not null, primary key
#  region_id  :integer          not null
#  locale     :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  body       :text
#

class Region < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
  end
end
