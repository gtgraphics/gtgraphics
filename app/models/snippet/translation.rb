# == Schema Information
#
# Table name: snippet_translations
#
#  id         :integer          not null, primary key
#  snippet_id :integer          not null
#  locale     :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)
#  body       :text
#

class Snippet < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    include GlobalizedModelTouchable
    include UniquelyTranslated

    acts_as_uniquely_translated :snippet_id

    validates :name, presence: true
  end
end
