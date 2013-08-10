# == Schema Information
#
# Table name: menu_items
#
#  id                    :integer          not null, primary key
#  menu_item_target_id   :integer
#  menu_item_target_type :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  parent_id             :integer
#  lft                   :integer          not null
#  rgt                   :integer          not null
#  depth                 :integer
#

class MenuItem < ActiveRecord::Base
  include Translatable
  
  TARGET_TYPES = %w(
    MenuItem::Link
    MenuItem::Record
  )

  acts_as_nested_set

  translates :title

  belongs_to :menu_item_target, polymorphic: true, dependent: :destroy

  validates :menu_item_target_id, presence: true
  validates :menu_item_target_type, presence: true, inclusion: { in: TARGET_TYPES }

  default_scope -> { order(:lft) }

  alias_attribute :target_id, :menu_item_target_id
  alias_attribute :target_type, :menu_item_target_type

  accepts_nested_attributes_for :translations
  accepts_nested_attributes_for :menu_item_target

  def build_menu_item_target(attributes = {})
    raise 'no target type defined' if menu_item_target_type.blank?
    self.menu_item_target = menu_item_target_type.constantize.new(attributes)
  end

  alias_method :build_target, :build_menu_item_target
end