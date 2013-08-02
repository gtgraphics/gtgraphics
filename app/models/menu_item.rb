# == Schema Information
#
# Table name: menu_items
#
#  id          :integer          not null, primary key
#  record_id   :integer
#  record_type :string(255)
#  position    :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class MenuItem < ActiveRecord::Base
  RECORD_TYPES = %w(
    Album
    Image
    Page
  )

  acts_as_nested_set

  translates :title

  belongs_to :record, polymorphic: true

  validates :title, presence: true
  validates :record_id, presence: true
  validates :record_type, presence: true, inclusion: { in: RECORD_TYPES }

  # default_scope -> { order(:lft) }
end
