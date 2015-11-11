# == Schema Information
#
# Table name: providers
#
#  id              :integer          not null, primary key
#  name            :string
#  logo            :string
#  logo_updated_at :datetime
#  asset_token     :string
#  created_at      :datetime
#  updated_at      :datetime
#

class Provider < ActiveRecord::Base
  has_many :shop_links, class_name: 'Image::ShopLink', dependent: :delete_all
  has_many :social_links, class_name: 'User::SocialLink', dependent: :destroy
  has_many :users, through: :user_providers

  mount_uploader :logo, Provider::LogoUploader

  after_initialize :generate_asset_token, unless: :asset_token?
  before_save :set_logo_updated_at, if: [:logo?, :logo_changed?]

  validates :name, presence: true

  sanitizes :name, with: :strip

  def to_param
    "#{id}-#{name.parameterize}"
  end

  private

  def generate_asset_token
    self.asset_token = SecureRandom.uuid
  end

  def set_logo_updated_at
    self.logo_updated_at = DateTime.now
  end
end
