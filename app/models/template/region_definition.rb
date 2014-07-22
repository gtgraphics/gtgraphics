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

    RESERVED_LABELS = %w(new edit).freeze

    acts_as_list scope: :template
    
    belongs_to :template, inverse_of: :region_definitions, touch: true
    has_many :regions, class_name: 'Page::Region', dependent: :destroy, inverse_of: :definition, foreign_key: :definition_id

    validates :label, presence: true, exclusion: { in: RESERVED_LABELS, allow_blank: true }, uniqueness: { scope: :template, allow_blank: true }
    validates :template, presence: true

    before_validation :set_label, if: :name?, unless: :label?
    before_validation :sanitize_label, if: :label?
    before_validation :set_name, if: :label?, unless: :name?

    default_scope -> { order(:position) }

    def to_param
      label
    end

    def to_s
      label
    end

    private
    def sanitize_label
      I18n.with_locale(I18n.default_locale) do
        self.label = label.parameterize.underscore
      end
    end

    def set_label
      self.label = name.parameterize.underscore
    end

    def set_name
      self.name = label.titleize
    end
  end
end
