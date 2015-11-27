# == Schema Information
#
# Table name: project_translations
#
#  id                   :integer          not null, primary key
#  project_id           :integer          not null
#  locale               :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  title                :string
#  description          :text
#  url                  :string
#  project_translations :string
#  project_type         :string
#

class Project< ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    include UniquelyTranslated

    acts_as_uniquely_translated :project_id
  end
end
