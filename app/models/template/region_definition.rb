# == Schema Information
#
# Table name: region_definitions
#
#  id          :integer          not null, primary key
#  template_id :integer
#  label       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Template < ActiveRecord::Base
  class RegionDefinition < ActiveRecord::Base
    self.table_name = 'region_definitions'

    belongs_to :template
    has_many :regions, class_name: '::Region', foreign_key: :definition_id, dependent: :destroy

    validates :template_id, presence: true
    validates :label, presence: true
  end
end
