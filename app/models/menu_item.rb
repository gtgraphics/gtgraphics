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
  
  RECORD_TYPES = %w(
    Album
    Image
    Page
  )

  acts_as_nested_set

  translates :title

  belongs_to :menu_item_target, polymorphic: true, dependent: :destroy

  validates :menu_item_target_id, presence: true
  validates :menu_item_target_type, presence: true, inclusion: { in: RECORD_TYPES }

  # default_scope -> { order(:lft) }
end
