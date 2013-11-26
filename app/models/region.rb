# == Schema Information
#
# Table name: regions
#
#  id            :integer          not null, primary key
#  definition_id :integer
#  page_id       :integer
#  body          :text
#  created_at    :datetime
#  updated_at    :datetime
#

class Region < ActiveRecord::Base
  belongs_to :definition, class_name: 'RegionDefinition'
  belongs_to :page
  has_one :template, -> { readonly }, through: :definition

  delegate :label, to: :definition, prefix: true, allow_nil: true

  translates :body, fallbacks_for_empty_translations: true

  validates :definition_id, presence: true
end