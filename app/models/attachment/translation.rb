# == Schema Information
#
# Table name: attachment_translations
#
#  id            :integer          not null, primary key
#  attachment_id :integer          not null
#  locale        :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :string
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
