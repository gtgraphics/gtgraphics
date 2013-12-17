# == Schema Information
#
# Table name: homepage_quote_translations
#
#  id                :integer          not null, primary key
#  homepage_quote_id :integer          not null
#  locale            :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  body              :text
#

class Homepage < ActiveRecord::Base
  class Quote < ActiveRecord::Base
    class Translation < Globalize::ActiveRecord::Translation
      validates :body, presence: true
    end
  end
end
