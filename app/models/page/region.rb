# == Schema Information
#
# Table name: page_regions
#
#  id            :integer          not null, primary key
#  definition_id :integer
#  page_id       :integer
#  body          :text
#  created_at    :datetime
#  updated_at    :datetime
#

class Page < ActiveRecord::Base
  class Region < ActiveRecord::Base
    belongs_to :page, inverse_of: :regions
    belongs_to :definition, class_name: 'Template::RegionDefinition', inverse_of: :regions
    has_one :template, through: :definition

    translates :body, fallbacks_for_empty_translations: true

    validates :page_id, presence: true, strict: true
    validates :definition_id, presence: true, strict: true

    delegate :label, to: :definition, prefix: true

    class << self
      def labelled(label)
        joins(:definition).where(template_region_definitions: { label: label })
      end
    end
  end
end
