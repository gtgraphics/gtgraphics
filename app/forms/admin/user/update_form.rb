class Admin::User::UpdateForm < Form
  handles :user

  delegate_attributes :first_name, :last_name, :email, :preferred_locale,
                      :twitter_username

  attribute :reset_password, Boolean, default: false
  attribute :generate_password, Boolean, default: true
  attribute :password, String

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, email: true
  validate :verify_email_uniqueness, if: -> { email.present? }
  validates :preferred_locale, inclusion: { in: -> { I18n.available_locales.map(&:to_s) } }, allow_blank: true
  validates :password, presence: true, confirmation: { unless: :generate_password? }, if: :reset_password?

  before_validation :sanitize_email_address, -> { email.present? }
  before_validation :set_generated_password, if: [:reset_password?, :generate_password?]
  after_submit :send_generated_password, if: [:reset_password?, :generate_password?]

  def perform
    user.password = password if reset_password?
    user.save!
  end

  private
  def sanitize_email_address
    self.email = email.downcase
  end

  def set_generated_password
    self.password = ::User.generate_password
  end

  def send_generated_password
    Admin::User::PasswordMailer.changed_password_email(user, password).deliver
  end

  def verify_email_uniqueness
    errors.add :email, :taken if ::User.without(user).exists?(email: email)
  end
end
