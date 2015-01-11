class Admin::User::AccountUpdateForm < Admin::User::UpdateForm
  attribute :current_password, String

  validates :current_password, presence: true, if: :reset_password?
  validate :verify_current_password_validity, if: -> { current_password.present? and reset_password? }

  private

  def verify_current_password_validity
    errors.add :current_password, :invalid unless ::User.authenticate(user.email, current_password)
  end
end
