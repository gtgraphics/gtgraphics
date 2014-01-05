# == Schema Information
#
# Table name: regions
#
#  id              :integer          not null, primary key
#  definition_id   :integer
#  page_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  regionable_id   :integer
#  regionable_type :string(255)
#

class Region < ActiveRecord::Base
  EMBEDDED_TYPE = 'Region::Content'.freeze
  REFERENCED_TYPE = 'Snippet'.freeze
  REGIONABLE_TYPES = [REFERENCED_TYPE, EMBEDDED_TYPE].freeze

  belongs_to :definition, class_name: 'RegionDefinition', inverse_of: :regions
  belongs_to :page, inverse_of: :regions
  belongs_to :regionable, polymorphic: true
  has_one :template, -> { readonly }, through: :definition

  delegate :label, to: :definition, prefix: true, allow_nil: true
  delegate :body, to: :regionable

  validates :definition_id, presence: true
  validates :regionable, presence: true
  validates :regionable_id, presence: true, if: :referenced?
  validates :regionable_type, presence: true, inclusion: { in: REGIONABLE_TYPES }

  after_destroy :destroy_regionable, if: :embedded?

  scope :embedded, -> { where(type: EMBEDDED_TYPE) }
  scope :referenced, -> { where(type: REFERENCED_TYPE) }

  class << self
    def regionable_types
      REGIONABLE_TYPES
    end
  end

  def build_regionable(attributes = {})
    raise 'invalid regionable type' unless regionable_class
    self.regionable = regionable_class.new(attributes)
  end

  def embedded?
    regionable_type == EMBEDDED_TYPE
  end
  alias_method :content?, :embedded?

  def referenced?
    regionable_type == REFERENCED_TYPE
  end
  alias_method :snippet?, :referenced?

  def regionable_attributes=(attributes)
    raise 'no regionable type specified' if regionable_class.nil?
    if regionable_type_changed? or new_record?
      build_regionable(attributes)
    else
      self.regionable.attributes = attributes
    end
  end

  def regionable_class
    regionable_type.in?(REGIONABLE_TYPES) ? regionable_type.constantize : nil
  end

  private
  def destroy_regionable
    regionable.try(:destroy)
  end
end
