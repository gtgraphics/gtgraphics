# == Schema Information
#
# Table name: page_region_translations
#
#  id             :integer          not null, primary key
#  page_region_id :integer          not null
#  locale         :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  body           :text
#

class Page < ActiveRecord::Base
  class Region < ActiveRecord::Base
    class Translation < Globalize::ActiveRecord::Translation
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
