# == Schema Information
#
# Table name: page_translations
#
#  id               :integer          not null, primary key
#  page_id          :integer          not null
#  locale           :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  contents         :text
#  meta_description :text
#  meta_keywords    :text
#

class Page < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    validates :title, presence: true

    store :contents
  end
end
