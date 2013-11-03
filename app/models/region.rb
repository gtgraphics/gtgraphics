# == Schema Information
#
# Table name: regions
#
#  id              :integer          not null, primary key
#  regionable_id   :integer
#  regionable_type :string(255)
#  definition_id   :integer
#  content         :text
#  created_at      :datetime
#  updated_at      :datetime
#

class Region < ActiveRecord::Base
  REGIONABLE_TYPES = %w(
    Content::Translation
  ).freeze

  belongs_to :definition, class_name: 'Template::RegionDefinition'
  belongs_to :regionable, polymorphic: true

  validates :regionable_type, presence: true, inclusion: { in: REGIONABLE_TYPES }
  validates :definition_id, presence: true

  class << self
    def regionable_types
      REGIONABLE_TYPES
    end
  end
end