# == Schema Information
#
# Table name: redirections
#
#  id                  :integer          not null, primary key
#  destination_page_id :integer
#  destination_url     :string(255)
#  external            :boolean          default(FALSE), not null
#  created_at          :datetime
#  updated_at          :datetime
#

class Redirection < ActiveRecord::Base
  include BatchTranslatable
  include Embeddable

  self.bound_to_page = true

  belongs_to :destination_page, class_name: 'Page'

  translates :title, fallbacks_for_empty_translations: true

  validates :destination_page_id, presence: true, if: :internal?
  validates :destination_url, presence: true, url: true, if: :external?

  before_validation :clear_obsolete_destination_attribute

  acts_as_batch_translatable

  def internal?
    !external?
  end

  private
  def clear_obsolete_destination_attribute
    if external?
      self.destination_page = nil
    else
      self.destination_url = nil
    end
  end
end