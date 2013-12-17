# == Schema Information
#
# Table name: quotes
#
#  id     :integer          not null, primary key
#  author :string(255)
#

class Quote < ActiveRecord::Base
  translates :body, fallbacks_for_empty_translations: true

  validates :author, presence: true

  class << self
    def random
      order('RANDOM()').first
    end
  end
end
