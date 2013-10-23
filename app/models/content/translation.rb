# == Schema Information
#
# Table name: content_translations
#
#  id         :integer          not null, primary key
#  content_id :integer          not null
#  locale     :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  title      :string(255)
#  content    :text
#

class Content < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    validates :title, presence: true
  end
end
