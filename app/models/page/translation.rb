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
    validates :title, presence: true

    serialize :meta_keywords, Array

    def meta_keyword_tokens
      @meta_keyword_tokens ||= meta_keywords.join(',')
    end

    def meta_keyword_tokens=(tokens)
      self.meta_keywords = tokens.split(',')
      @meta_keyword_tokens = tokens
    end
  end
end
