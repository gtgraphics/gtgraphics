# == Schema Information
#
# Table name: menu_items
#
#  id          :integer          not null, primary key
#  record_id   :integer
#  record_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  parent_id   :integer
#  lft         :integer          not null
#  rgt         :integer          not null
#  depth       :integer
#  target      :string(255)
#

class MenuItem < ActiveRecord::Base
  RECORD_TYPES = %w(
    MenuItem::Link
    Page
    Album
    Image
  ).freeze

  acts_as_nested_set

  translates :title

  belongs_to :record, polymorphic: true

  validates :record_id, presence: true, unless: :link?
  validates :record_type, presence: true, inclusion: { in: RECORD_TYPES }
  validates :url, presence: true, if: :link?

  after_destroy :destroy_link

  default_scope -> { order(:lft) }

  RECORD_TYPES.each do |record_type|
    scope record_type.demodulize.underscore.pluralize, -> { where(record_type: record_type) }

    define_method "#{record_type.demodulize.underscore}?" do
      self.record_type == record_type
    end
  end

  accepts_nested_attributes_for :translations

  def build_record(attributes = {})
    raise 'no record type defined' if record_type.blank?
    self.record = record_type.constantize.new(attributes)
  end

  def url
    if link?
      record.try(:url)
    else
      RequestStore.store[:controller_context].try(:polymorphic_url, record)
    end
  end

  def url=(url)
    if link?
      self.record ||= build_record
      record.url = url
    else
      raise "cannot set URL for #{record.inspect} manually"
    end
  end

  private
  def destroy_link
    record.destroy if link?
  end
end
