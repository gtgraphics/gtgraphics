# == Schema Information
#
# Table name: image_style_translations
#
#  id             :integer          not null, primary key
#  image_style_id :integer          not null
#  locale         :string(255)      not null
#  created_at     :datetime
#  updated_at     :datetime
#  name           :string(255)
#

class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    class Translation < Globalize::ActiveRecord::Translation
      validates :name, presence: true
    end
  end
end
