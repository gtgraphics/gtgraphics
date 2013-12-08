class InitialUserPasswordMailerJob < Struct.new(:user_id, :locale)
  include Job

  def perform
    I18n.with_locale(locale) do
      UserMailer.send_initial_password_email(user).deliver
    end
  end

  def user
    @user ||= User.find(user_id)
  end
end