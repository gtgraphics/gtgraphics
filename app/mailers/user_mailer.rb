class UserMailer < ActionMailer::Base
  default from: %{"GT Graphics" <noreply@gtgraphics.de>}

  def send_initial_password_email(user)
    @user = user
    mail to: @user.id
  end

  def send_updated_password_email(user)
    @user = user
    mail to: @user.id
  end
end