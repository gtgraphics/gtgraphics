# TODO: Replace with Sorcery: https://github.com/NoamB/sorcery

class Admin::SessionsController < Admin::ApplicationController
  skip_before_action :require_login, only: %i(new create)
  
  before_action if: :logged_in?, only: %i(new create) do
    redirect_to :admin_root
  end

  def new
    @sign_in_activity = Admin::User::LoginActivity.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @sign_in_activity = Admin::User::LoginActivity.new(login_params)
    if @sign_in_activity.valid?
      auto_login @sign_in_activity.user, @sign_in_activity.permanent?
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