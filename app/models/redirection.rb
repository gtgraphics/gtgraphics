# == Schema Information
#
# Table name: redirections
#
#  id                  :integer          not null, primary key
#  destination_page_id :integer
#  destination_url     :string(255)
#  external            :boolean          default(FALSE), not null
#

class Redirection < ActiveRecord::Base
  include BatchTranslatable
  include Embeddable

  self.bound_to_page = true

  translates :title

  belongs_to :destination_page, class_name: 'Page'

  validates :destination_page_id, presence: true, if: :internal?
  validates :destination_url, presence: true, url: true, if: :external?

  def internal?
    !external?
  end
end
