class MenuItem < ActiveRecord::Base
  RECORD_TYPES = %w(
    Album
    Image
    Page
  )

  acts_as_list

  translates :title

  belongs_to :record, polymorphic: true

  validates :title, presence: true
  validates :record_id, presence: true
  validates :record_type, presence: true, inclusion: { in: RECORD_TYPES }
end