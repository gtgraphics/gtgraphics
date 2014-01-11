# == Schema Information
#
# Table name: region_content_translations
#
#  id                :integer          not null, primary key
#  region_content_id :integer          not null
#  locale            :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  body              :text
#

class Region < ActiveRecord::Base
  class Content < ActiveRecord::Base
    class Translation < Globalize::ActiveRecord::Translation
      include UniquelyTranslated

      acts_as_uniquely_translated :region_content_id
    end
  end
end
