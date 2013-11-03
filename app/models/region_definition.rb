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

class RegionDefinition < ActiveRecord::Base
  belongs_to :template
  has_many :regions, foreign_key: :definition_id, dependent: :destroy

  validates :template_id, presence: true
  validates :label, presence: true

  before_validation :sanitize_label, if: -> { label.present? }

  private
  def sanitize_label
    self.label = label.parameterize('_')
  end
end