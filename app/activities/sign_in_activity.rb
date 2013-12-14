class SignInActivity < Activity
  attribute :email, String
  attribute :password, String
  attribute :permanent, Boolean, default: false

  validates :email, presence: true
  validates :password, presence: true
  validate :validate_credentials
  validate :validate_user_is_unlocked

  before_validation :set_user
  after_validation :succeed_or_fail_sign_in

  attr_reader :user

  private
  def set_user
    @user = User.find_by(email: email) if email.present?
  end

  def succeed_or_fail_sign_in
    if user and user.is_a?(Authenticatable::Lockable)
      if errors.any?
        user.fail_sign_in!
      else
        user.succeed_sign_in!
      end
    end
  end

  def validate_credentials
    if email.present? and password.present? and (user.nil? or !user.authenticate(password))
      errors.add :email, :invalid
      errors.add :password, :invalid
    end
  end

  def validate_user_is_unlocked
    if user and user.is_a?(Authenticatable::Lockable) and user.locked?
      errors.add :base, :locked
    end
  end
end