class Admin::User::AccountUpdateForm < Admin::User::UpdateForm
  attribute :current_password, String

  validates :current_password, presence: true, if: :reset_password?
  validate :verify_current_password_validity, if: :validate_password?

  private

  def verify_current_password_validity
    return true if ::User.authenticate(user.email, current_password)
    errors.add :current_password, :invalid
  end

  def validate_password?
    current_password.present? && reset_password?
  end
end
