class PasswordMailer < ActionMailer::Base
  default from: %{"GT Graphics" <noreply@gtgraphics.de>}

  def send_initial_password_email(user, password)
    @user = user
    @password = password
    mail to: @user.mail_formatted_name, subject: translate('mailers.password_mailer.send_initial_password_email.subject', full_user_name: @user.full_name)
  end

  def send_changed_password_email(user, password)
    @user = user
    @password = password
    mail to: @user.mail_formatted_name, subject: translate('mailers.password_mailer.send_changed_password_email.subject', full_user_name: @user.full_name)
  end
end