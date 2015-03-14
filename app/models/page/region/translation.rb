# == Schema Information
#
# Table name: page_region_translations
#
#  id             :integer          not null, primary key
#  page_region_id :integer          not null
#  locale         :string(255)      not null
#  created_at     :datetime
#  updated_at     :datetime
#  body           :text
#

class Page < ActiveRecord::Base
  class Region < ActiveRecord::Base
    class Translation < Globalize::ActiveRecord::Translation
      include GlobalizedModelTouchable
      include UniquelyTranslated

      acts_as_uniquely_translated :page_region_id

      before_validation :clear_body, if: [:body?, :body_changed?]

      private

      def clear_body
        self.body = nil if body.in?(Page::Region::EMPTY_BODY_CONTENTS)
      end
    end
  end
end
