# == Schema Information
#
# Table name: project_page_translations
#
#  id              :integer          not null, primary key
#  project_page_id :integer          not null
#  locale          :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#  name            :string(255)
#  description     :text
#

class Page < ActiveRecord::Base
  class Project < ActiveRecord::Base
    class Translation < Globalize::ActiveRecord::Translation
      include UniquelyTranslated

      acts_as_uniquely_translated :project_page_id
      sanitizes :name, with: :squish
    end
  end
end
