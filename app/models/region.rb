# == Schema Information
#
# Table name: regions
#
#  id            :integer          not null, primary key
#  definition_id :integer
#  page_id       :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Region < ActiveRecord::Base
  include HtmlContainable
  
  belongs_to :definition, class_name: 'RegionDefinition', inverse_of: :regions
  belongs_to :page, inverse_of: :regions
  has_one :template, -> { readonly }, through: :definition

  delegate :label, to: :definition, prefix: true, allow_nil: true

  translates :body, fallbacks_for_empty_translations: true

  validates :definition_id, presence: true
end
