# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  first_name                      :string(255)
#  last_name                       :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  preferences                     :text
#  email                           :string(255)      not null
#  crypted_password                :string(255)      not null
#  salt                            :string(255)      not null
#  remember_me_token               :string(255)
#  remember_me_token_expires_at    :datetime
#  reset_password_token            :string(255)
#  reset_password_token_expires_at :datetime
#  reset_password_email_sent_at    :datetime
#  failed_logins_count             :integer          default(0)
#  lock_expires_at                 :datetime
#  unlock_token                    :string(255)
#  last_login_at                   :datetime
#  last_logout_at                  :datetime
#  last_activity_at                :datetime
#  last_login_from_ip_address      :string(255)
#  twitter_username                :string(255)
#  photo                           :string(255)
#  photo_updated_at                :datetime
#

class User < ActiveRecord::Base
  include Authenticatable
  include Authorizable
  include Excludable
  include FileAttachable
  include PersistenceContextTrackable
  include User::Messaging

  store :preferences, accessors: [:preferred_locale]

  with_options foreign_key: :author_id, dependent: :nullify do |author|
    author.has_many :attachments
    author.has_many :images
    author.has_many :pages
    author.has_many :snippets
  end

  mount_uploader :photo, User::PhotoUploader

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, email: true,
                    uniqueness: { case_sensitive: false }
  validates :preferred_locale,
            inclusion: { in: -> { I18n.available_locales.map(&:to_s) } },
            allow_blank: true

  before_validation :sanitize_preferred_locale
  before_save :sanitize_email_address, if: :email?
  before_save :set_photo_updated_at, if: [:photo?, :photo_changed?]

  default_scope -> { order(:first_name, :last_name) }

  def self.find_by_name(name)
    find_by_name!(name) rescue nil
  end

  def self.find_by_name!(name)
    find_by!("(#{table_name}.first_name || ' ' || #{table_name}.last_name) = ?",
             name)
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  alias_method :name, :full_name

  def rfc5322
    if full_name.present?
      %("#{full_name}" <#{email}>)
    else
      email
    end
  end

  def to_liquid
    attributes.slice(*%w(first_name last_name email)).merge(
      'name' => full_name,
      'full_name' => full_name
    )
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def to_s
    full_name
  end

  private

  def sanitize_email_address
    self.email = email.downcase
  end

  def sanitize_preferred_locale
    self.preferred_locale = preferred_locale.to_s.downcase.presence
  end

  def set_photo_updated_at
    self.photo_updated_at = DateTime.now
  end
end
