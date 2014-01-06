# == Schema Information
#
# Table name: regions
#
#  id                   :integer          not null, primary key
#  definition_id        :integer
#  page_id              :integer
#  created_at           :datetime
#  updated_at           :datetime
#  concrete_region_id   :integer
#  concrete_region_type :string(255)
#  regionable_id        :integer
#  regionable_type      :string(255)
#

class Region < ActiveRecord::Base
  EMBEDDED_TYPE = 'Region::Content'.freeze
  REFERENCED_TYPE = 'Snippet'.freeze
  CONCRETE_REGION_TYPES = [REFERENCED_TYPE, EMBEDDED_TYPE].freeze

  belongs_to :definition, class_name: 'RegionDefinition', inverse_of: :regions
  belongs_to :regionable, polymorphic: true # e.g. Page::Content
  belongs_to :concrete_region, polymorphic: true
  has_one :template, -> { readonly }, through: :definition

  delegate :label, to: :definition, prefix: true, allow_nil: true
  delegate :body, to: :concrete_region

  validates :definition_id, presence: true
  validates :concrete_region, presence: true, if: :embedded?
  validates :concrete_region_id, presence: true, if: :referenced?
  validates :concrete_region_type, presence: true, inclusion: { in: CONCRETE_REGION_TYPES }
  validates :regionable, presence: true

  after_destroy :destroy_concrete_region, if: :embedded?

  scope :embedded, -> { where(type: EMBEDDED_TYPE) }
  scope :referenced, -> { where(type: REFERENCED_TYPE) }

  accepts_nested_attributes_for :concrete_region
  accepts_nested_attributes_for :regionable

  class << self
    def concrete_region_types
      CONCRETE_REGION_TYPES
    end
  end

  def build_concrete_region(attributes = {})
    raise 'invalid region type' unless concrete_region_class
    self.concrete_region = concrete_region_class.new(attributes)
  end

  def concrete_region_attributes=(attributes)
    raise 'invalid region type' unless concrete_region_class
    if concrete_region_type_changed? or new_record?
      build_concrete_region(attributes)
    else
      concrete_region.attributes = attributes
    end
  end

  def concrete_region_class
    concrete_region_type.in?(CONCRETE_REGION_TYPES) ? concrete_region_type.constantize : nil
  end

  def embedded?
    concrete_region_type == EMBEDDED_TYPE
  end
  alias_method :content?, :embedded?

  def referenced?
    concrete_region_type == REFERENCED_TYPE
  end
  alias_method :snippet?, :referenced?

  private
  def destroy_concrete_region
    concrete_region.try(:destroy)
  end
end
