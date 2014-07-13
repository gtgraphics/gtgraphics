class Admin::User::LoginActivity < Activity
  handles :user

  attribute :email, String
  attribute :password, String
  attribute :permanent, Boolean, default: false

  validates :email, presence: true, email: true
  validates :password, presence: true
  validate :verify_credentials_and_load_user, if: -> { email.present? and password.present? }

  before_validation :sanitize_email_address, -> { email.present? }

  private
  def sanitize_email_address
    self.email = email.downcase
  end

  def verify_credentials_and_load_user
    self.user = User.authenticate(email, password)
    errors.add :base, :invalid if user.nil?
  end
end