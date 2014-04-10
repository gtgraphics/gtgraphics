# == Schema Information
#
# Table name: image_translations
#
#  id          :integer          not null, primary key
#  image_id    :integer          not null
#  locale      :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  title       :string(255)
#  description :text
#

class Image < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    include GlobalizedModelTouchable
    include Sanitizable
    include UniquelyTranslated

    acts_as_uniquely_translated :image_id
    
    sanitizes :title, with: :squish

    validates :title, presence: true
  end
end
