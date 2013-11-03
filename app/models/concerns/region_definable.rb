module RegionDefinable
  extend ActiveSupport::Concern

  included do
    has_many :region_definitions, class_name: 'Template::Region', dependent: :destroy
  end
end