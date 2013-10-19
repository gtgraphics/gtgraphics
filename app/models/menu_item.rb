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
#  target                :string(255)
#  new_window            :boolean          default(FALSE), not null
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

  after_destroy :destroy_link

  default_scope -> { order(:lft) }

  accepts_nested_attributes_for :translations, allow_destroy: true

  alias_attribute :target, :menu_item_target
  alias_attribute :target_id, :menu_item_target_id
  alias_attribute :target_type, :menu_item_target_type

  TARGET_TYPES.each do |target_type|
    scope target_type.demodulize.underscore.pluralize, -> { where(menu_item_target_type: target_type) }

    define_method "#{target_type.demodulize.underscore}?" do
      self.target_type == target_type
    end
  end

  class Translation < Globalize::ActiveRecord::Translation
    validates :title, presence: true
  end

  class << self
    def target_types
      TARGET_TYPES
    end
  end

  def build_menu_item_target(attributes = {})
    raise 'no record type defined' if record_type.blank?
    self.target = record_type.constantize.new(attributes)
  end

  alias_method :build_target, :build_menu_item_target

  private
  def destroy_link
    target.destroy if link?
  end
end
