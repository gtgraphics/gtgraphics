class Admin::User::PasswordMailer < Admin::ApplicationMailer
  def initial_password_email(user, password)
    @user = user
    @password = password
    mail to: @user.rfc5322,
         subject: translate('mailers.password_mailer.send_initial_password_email.subject', user_name: @user.full_name)
  end

  def changed_password_email(user, password)
    @user = user
    @password = password
    mail to: @user.rfc5322,
         subject: translate('mailers.password_mailer.send_changed_password_email.subject', user_name: @user.full_name)
  end
end