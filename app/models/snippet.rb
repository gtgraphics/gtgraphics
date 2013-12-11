# == Schema Information
#
# Table name: snippets
#
#  id         :integer          not null, primary key
#  author_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Snippet < ActiveRecord::Base
  include Authorable
  include BatchTranslatable

  has_many :regions, as: :regionable, dependent: :destroy

  translates :name, :body, fallbacks_for_empty_translations: true

  acts_as_authorable
  acts_as_batch_translatable
end
