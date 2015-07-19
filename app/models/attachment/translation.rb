# == Schema Information
#
# Table name: attachment_translations
#
#  id            :integer          not null, primary key
#  attachment_id :integer          not null
#  locale        :string(255)      not null
#  created_at    :datetime
#  updated_at    :datetime
#  title         :string(255)
#  description   :text
#

class Attachment < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    include UniquelyTranslated

    acts_as_uniquely_translated :attachment_id

    sanitizes :title, with: :squish

    validates :title, presence: true
  end
end
