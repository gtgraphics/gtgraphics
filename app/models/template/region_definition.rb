# == Schema Information
#
# Table name: template_region_definitions
#
#  id          :integer          not null, primary key
#  template_id :integer
#  label       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  name        :string(255)
#  position    :integer          not null
#

class Template < ActiveRecord::Base
  class RegionDefinition < ActiveRecord::Base
    include PersistenceContextTrackable

    RESERVED_LABELS = %w(new).freeze

    acts_as_list scope: :template
    
    belongs_to :template, inverse_of: :region_definitions
    has_many :regions, class_name: 'Page::Region', dependent: :destroy, inverse_of: :definition, foreign_key: :definition_id

    validates :label, presence: true, exclusion: { in: RESERVED_LABELS }, uniqueness: { scope: :template_id }
    validates :template, presence: true

    before_validation :sanitize_label, if: :label?
    before_validation :set_name, if: :label?

    default_scope -> { order(:position) }

    def name
      label.titleize
    end

    def to_param
      label
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

    def set_name
      self.name = label.titleize
    end
  end
end
