# == Schema Information
#
# Table name: gallery_translations
#
#  id          :integer          not null, primary key
#  gallery_id  :integer          not null
#  locale      :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  title       :string(255)
#  description :text
#

class Gallery < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    validates :title, presence: true
  end
end
