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
    include BatchTranslatable
    
    belongs_to :definition, class_name: 'Template::RegionDefinition', inverse_of: :regions
    has_one :template, through: :definition

    translates :body, fallbacks_for_empty_translations: true

    acts_as_batch_translatable

    validates :definition_id, presence: true

    delegate :label, to: :definition, prefix: true, allow_nil: true
    delegate :body, to: :concrete_region

    class << self
      def labelled(label)
        joins(:definition).where(region_definitions: { label: label })
      end
    end
  end
end
