# == Schema Information
#
# Table name: quote_translations
#
#  id         :integer          not null, primary key
#  quote_id   :integer          not null
#  locale     :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  body       :text
#

class Quote < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    validates :body, presence: true
  end
end
