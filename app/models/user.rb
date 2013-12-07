# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  locale                 :string(255)
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
  validates :locale, length: { is: 2, allow_blank: true }

  before_validation :sanitize_locale

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
  end

  def current?
    self == self.class.current
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def generate_password?
    @generate_password = false unless defined? @generate_password
    @generate_password
  end
  alias_method :generate_password, :generate_password?

  def generate_password=(generate_password)
    @generate_password = generate_password.in?(ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES)
  end

  def recipient
    if full_name.present?
      %{"#{full_name}" <#{email}>}
    else
      email
    end
  end

  private
  def sanitize_locale
    self.locale = locale.to_s.downcase.presence
  end
end
