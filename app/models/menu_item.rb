# == Schema Information
#
# Table name: menu_items
#
#  id                    :integer          not null, primary key
#  menu_item_target_id   :integer
#  menu_item_target_type :string(255)
#  parent_id             :integer
#  lft                   :integer          not null
#  rgt                   :integer          not null
#  depth                 :integer
#  created_at            :datetime
#  updated_at            :datetime
#  target                :string(255)
#

class MenuItem < ActiveRecord::Base
  TARGET_TYPES = %w(
    MenuItem::Link
    Page
    Album
    Image
  ).freeze

  acts_as_nested_set

  translates :title

  belongs_to :menu_item_target, polymorphic: true

  validates :menu_item_target_id, presence: true, unless: :link?
  validates :menu_item_target_type, presence: true, inclusion: { in: TARGET_TYPES }
  # validates :url, presence: true, url: true, if: :link?

  after_destroy :destroy_link

  accepts_nested_attributes_for :translations, allow_destroy: true

  default_scope -> { order(:lft) }

  TARGET_TYPES.each do |target_type|
    scope target_type.demodulize.underscore.pluralize, -> { where(menu_item_target_type: target_type) }

    define_method "#{target_type.demodulize.underscore}?" do
      self.target_type == target_type
    end
  end

  class << self
    def target_types
      TARGET_TYPES
    end
  end

  def build_record(attributes = {})
    raise 'no record type defined' if record_type.blank?
    self.record = record_type.constantize.new(attributes)
  end

  private
  def destroy_link
    record.destroy if link?
  end
end
