class Admin::SessionsController < Admin::ApplicationController
  skip_before_action :require_login, only: %i(new create)
  
  before_action if: :logged_in?, only: %i(new create) do
    redirect_to :admin_root
  end

  def new
    @user_login_activity = Admin::User::LoginActivity.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @user_login_activity = Admin::User::LoginActivity.new(login_params)
    if @user_login_activity.valid?
      auto_login @user_login_activity.user, @user_login_activity.permanent?
      respond_to do |format|
        format.html { redirect_back_or_to :admin_root }
      end
    else
      respond_to do |format|
        format.html { render :new }
      end
    end
  end

  def destroy
    logout
    respond_to do |format|
      format.html { redirect_to :admin_root }
    end
  end

  private
  def login_params
    params.require(:session).permit(:email, :password, :permanent)
  end
end