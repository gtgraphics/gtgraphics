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
  include PersistenceContextTrackable
  
  belongs_to :template, inverse_of: :region_definitions
  has_many :regions, dependent: :destroy, inverse_of: :definition, foreign_key: :definition_id

  validates :label, presence: true, uniqueness: { scope: :template_id }
  validates :template, presence: true

  before_validation :sanitize_label, if: -> { label.present? }

  default_scope -> { order(:label) }

  def to_s
    label
  end

  private
  def sanitize_label
    I18n.with_locale(I18n.default_locale) do
      self.label = label.parameterize('_')
    end
  end
end