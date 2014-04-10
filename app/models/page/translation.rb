# == Schema Information
#
# Table name: page_translations
#
#  id               :integer          not null, primary key
#  page_id          :integer          not null
#  locale           :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  title            :string(255)
#  meta_description :text
#  meta_keywords    :text
#

class Page < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    include GlobalizedModelTouchable
    include Sanitizable
    include UniquelyTranslated

    acts_as_uniquely_translated :page_id
    
    sanitizes :title, with: :squish

    validates :title, presence: true

    composed_of :meta_keywords, class_name: 'TokenCollection', mapping: %w(meta_keywords to_s), converter: :new
  end
end
