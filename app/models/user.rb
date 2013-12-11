# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  preferred_locale       :string(255)
#  email                  :string(255)      not null
#  encrypted_password     :string(255)      not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :addressed_contact_forms, class_name: 'ContactForm', join_table: 'contact_form_recipients', foreign_key: 'recipient_id', association_foreign_key: 'contact_form_id'

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  before_validation :sanitize_preferred_locale
  before_validation :set_generated_password, if: :generate_password?
  after_create :send_initial_password
  after_update :send_updated_password, if: :password_changed?

  default_scope -> { order(:first_name, :last_name) }

  class << self
    def anonymous?
      current.nil?
    end
    alias_method :signed_out?, :anonymous?

    def authenticated?
      !current.nil?
    end
    alias_method :signed_in?, :authenticated?

    def current
      Thread.current[:current_user]
    end

    def generate_password(length = 8)
      Devise.friendly_token.first(length)
    end
  end

  def change_password?
    @change_password = false unless defined? @change_password
    @change_password
  end
  alias_method :change_password, :change_password?

  def change_password=(change_password)
    @change_password = change_password.in?(ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES)
  end

  def current?
    self == self.class.current
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
  alias_method :name, :full_name

  def generate_password?
    @generate_password = new_record? unless defined? @generate_password
    @generate_password
  end
  alias_method :generate_password, :generate_password?

  def generate_password=(generate_password)
    @generate_password = generate_password.in?(ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES)
  end

  def password_changed?
    new_record? or password.present?
  end

  def preferred_locale_name
    I18n.translate(preferred_locale, scope: :languages) if preferred_locale.present?
  end

  def recipient
    if full_name.present?
      %{"#{full_name}" <#{email}>}
    else
      email
    end
  end

  private
  def sanitize_preferred_locale
    self.preferred_locale = preferred_locale.to_s.downcase.presence
  end

  def send_initial_password
    UserMailer.send_initial_password_email(self).deliver
  end

  def send_updated_password
    #UserMailer.send_updated_password_email(self).deliver
  end

  def set_generated_password
    self.password = self.password_confirmation = self.class.generate_password
  end
end
