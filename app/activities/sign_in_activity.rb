class SignInActivity
  include Activity

  attribute :email, String
  attribute :password, String
  attribute :remember_me, Boolean, default: false

  validates :email, presence: true, email: true
  validates :password, presence: true
  validate :validate_user_existence
  validate :validate_password_validity

  def user
    @user ||= (User.find_by(email: email) if email.present?)
  end

  private
  def invalidate_email_and_password!
    errors.add(:email, :invalid)
    errors.add(:password, :invalid)
  end

  def validate_password_validity
    errors.add(:password, :invalid) if user and !user.valid_password?(password)
  end

  def validate_user_existence
    errors.add(:email, :invalid) if user.nil?
  end
end