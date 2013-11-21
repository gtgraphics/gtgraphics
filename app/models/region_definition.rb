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
  has_many :regions, dependent: :destroy

  validates :label, presence: true, uniqueness: { scope: :template_id }
  validates :template_id, presence: true

  before_validation :sanitize_label

  def to_param
    label
  end

  private
  def sanitize_label
    self.label = label.parameterize('_') if label.present?
  end
end
