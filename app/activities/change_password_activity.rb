class ChangePasswordActivity < Activity
  attribute :user_id, Integer
  attribute :current_password, String
  attribute :generate_password, Boolean, default: false
  attribute :password, String
  attribute :password_confirmation, String

  validates :user_id, presence: true
  validates :current_password, presence: true, if: :user_is_current?
  validates :password, presence: true, confirmation: true, unless: :generate_password?
  validates :password_confirmation, presence: true, unless: :generate_password?
  validate :verify_current_password, if: :user_is_current?

  before_validation :set_generated_password, if: :generate_password?

  def perform
    # Save new Password in User
    user.password = user.password_confirmation = password
    user.save!
  end

  def user
    @user ||= User.find(user_id)
  end

  def user=(user)
    @user = user
    self.user_id = user.id
  end

  private
  def user_is_current?
    user and user.current?
  end

  def set_generated_password
    self.password = self.password_confirmation = User.generate_password
  end

  def verify_current_password
    errors.add(:current_password, :invalid) unless user.authenticate(current_password)
  end
end