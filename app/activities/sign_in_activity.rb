class SignInActivity < Activity
  attribute :email, String
  attribute :password, String
  attribute :permanent, Boolean, default: false

  validates :email, presence: true
  validates :password, presence: true
  validate :verify_credentials
  validate :verity_user_is_unlocked

  before_validation :set_user
  before_validation :remove_expired_lock
  after_validation :succeed_or_fail_sign_in

  attr_reader :user

  private
  def remove_expired_lock
    user.try(:remove_expired_lock!)
  end

  def set_user
    @user = User.find_by(email: email) if email.present?
  end

  def succeed_or_fail_sign_in
    if user and password.present? and user.is_a?(Authenticatable::Lockable) and user.unlocked?
      if errors.any?
        user.fail_sign_in!
      else
        user.succeed_sign_in!
      end
    end
  end

  def verify_credentials
    if email.present? and password.present? and (user.nil? or !user.authenticate(password))
      errors.add :email, :invalid
      errors.add :password, :invalid
    end
  end

  def verity_user_is_unlocked
    if user and user.is_a?(Authenticatable::Lockable) and user.locked?
      # errors.add :base, :locked
      errors.add :email, :invalid
      errors.add :password, :invalid
    end
  end
end