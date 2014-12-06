class Admin::User::LoginForm < Form
  EMAIL_DOMAIN = 'gtgraphics.de'

  handles :user

  attribute :login, String
  attribute :password, String
  attribute :permanent, Boolean, default: false

  validates :login, presence: true, email: { if: :login_via_email? }
  validates :password, presence: true
  validate :verify_credentials_and_load_user, if: [:login?, :password?]

  before_validation :sanitize_email_address, if: :login_via_email?

  def login_via_email?
    login? && login.include?('@')
  end

  private
  def sanitize_email_address
    self.email = email.downcase
  end

  def verify_credentials_and_load_user
    if login_via_email?
      email = self.login
    else
      email = "#{login}@#{EMAIL_DOMAIN}"
    end 
    self.user = User.authenticate(email, password)
    errors.add :base, :invalid if user.nil?
  end
end