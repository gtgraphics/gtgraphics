# == Schema Information
#
# Table name: template_translations
#
#  id          :integer          not null, primary key
#  template_id :integer          not null
#  locale      :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  name        :string(255)
#  description :text
#

class Template < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    include UniquelyTranslated

    acts_as_uniquely_translated :template_id

    validates :name, presence: true
  end
end
