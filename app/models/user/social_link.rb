# == Schema Information
#
# Table name: user_social_links
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  provider_id :integer
#  url         :string(255)
#  shop        :boolean          default(FALSE), not null
#  position    :integer
#

class User::SocialLink < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :provider

  acts_as_list scope: [:user, :shop]

  default_scope -> { order(:position) }

  validates :user, presence: true, strict: true
  validates :provider, presence: true,
                       uniqueness: { scope: [:user, :shop], allow_blank: true }
  validates :url, presence: true, url: true

  scope :networks, -> { where(shop: false) }
  scope :shops, -> { where(shop: true) }

  delegate :name, to: :provider, prefix: true, allow_nil: true

  sanitizes :url, with: :strip

  before_validation :set_default_protocol, if: :url?

  def to_param
    "#{id}-#{provider.name.parameterize}"
  end

  private

  def set_default_protocol
    self.url = "http://#{url}" if url != %r{\A(http|https)\://}
  end
end
