# == Schema Information
#
# Table name: page_regions
#
#  id            :integer          not null, primary key
#  definition_id :integer
#  page_id       :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Page < ActiveRecord::Base
  class Region < ActiveRecord::Base
    include Translatable
    
    belongs_to :page, inverse_of: :regions, touch: true
    belongs_to :definition, class_name: 'Template::RegionDefinition', inverse_of: :regions
    has_one :template, through: :definition

    translates :body, fallbacks_for_empty_translations: true

    validates :page_id, presence: true, strict: true
    validates :definition_id, presence: true, strict: true

    delegate :label, :name, to: :definition

    class << self
      def labelled(*labels)
        labels.flatten!
        joins(:definition).
        where(template_region_definitions: { label: labels.one? ? labels.first : labels }).
        readonly(false)
      end
    end

    def to_param
      label
    end
  end
end
