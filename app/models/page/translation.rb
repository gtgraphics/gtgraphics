# == Schema Information
#
# Table name: page_translations
#
#  id               :integer          not null, primary key
#  page_id          :integer          not null
#  locale           :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  title            :string
#  meta_description :text
#  meta_keywords    :text
#

class Page < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    include UniquelyTranslated

    acts_as_uniquely_translated :page_id

    composed_of :meta_keywords, class_name: 'TokenCollection',
                                mapping: %w(meta_keywords to_s), converter: :new
  end
end
