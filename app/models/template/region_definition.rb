# == Schema Information
#
# Table name: template_region_definitions
#
#  id          :integer          not null, primary key
#  template_id :integer
#  label       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Template < ActiveRecord::Base
  class RegionDefinition < ActiveRecord::Base
    include PersistenceContextTrackable
    
    belongs_to :template, inverse_of: :region_definitions
    has_many :regions, class_name: 'Page::Region', dependent: :destroy, inverse_of: :definition, foreign_key: :definition_id

    validates :label, presence: true, uniqueness: { scope: :template_id }
    validates :template, presence: true

    before_validation :sanitize_label, if: -> { label.present? }

    default_scope -> { order(:label) }

    def name
      label.titleize
    end

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
end
