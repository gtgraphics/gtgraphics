class Admin::User::RegistrationActivity < Activity
  handles :user

  attribute :first_name, String
  attribute :last_name, String
  attribute :email, String
  attribute :preferred_locale, String
  attribute :password, String
  attribute :generate_password, Boolean, default: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, email: true
  validate :verify_email_uniqueness, if: -> { email.present? }
  validates :preferred_locale, inclusion: { in: -> { I18n.available_locales.map(&:to_s) } }, allow_blank: true
  validates :password, presence: true, confirmation: { unless: :generate_password? }

  before_validation :sanitize_email_address, if: -> { email.present? }
  before_validation :set_generated_password, if: :generate_password?
  after_execute :send_generated_password, if: :generate_password?

  def perform
    self.user = ::User.create! do |user|
      user.first_name = first_name
      user.last_name = last_name
      user.email = email
      user.preferred_locale = preferred_locale
      user.password = password
    end
  end

  private
  def sanitize_email_address
    self.email = email.downcase
  end

  def set_generated_password
    self.password = ::User.generate_password
  end

  def send_generated_password
    Admin::User::PasswordMailer.initial_password_email(user, password).deliver 
  end

  def verify_email_uniqueness
    errors.add :email, :taken if ::User.exists?(email: email)
  end
end