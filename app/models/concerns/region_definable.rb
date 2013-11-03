module RegionDefinable
  extend ActiveSupport::Concern

  included do
    has_many :region_definitions, foreign_key: :template_id, dependent: :destroy
  end
end