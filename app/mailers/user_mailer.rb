class UserMailer < ActionMailer::Base
  default from: %{"GT Graphics" <noreply@gtgraphics.de>}

  def send_initial_password_email(user)
    @user = user
    mail to: @user.id, subject: translate('mailers.user_mailer.send_initial_password_email.subject', full_user_name: @user.full_name)
  end

  def send_updated_password_email(user)
    @user = user
    mail to: @user.id, subject: translate('mailers.user_mailer.send_updated_password_email.subject', full_user_name: @user.full_name)
  end
end