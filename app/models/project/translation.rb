# == Schema Information
#
# Table name: project_translations
#
#  id                   :integer          not null, primary key
#  project_id           :integer          not null
#  locale               :string(255)      not null
#  created_at           :datetime
#  updated_at           :datetime
#  title                :string(255)
#  description          :text
#  url                  :string(255)
#  project_translations :string(255)
#  project_type         :string(255)
#

class Project< ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    include UniquelyTranslated

    acts_as_uniquely_translated :project_id
  end
end
