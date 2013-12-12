#class Admin::SessionsController < Devise::SessionsController
#  layout 'admin/application'
#end
class Admin::SessionsController < Admin::ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    @sign_in_activity = SignInActivity.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @sign_in_activity = SignInActivity.new(sign_in_params)
    respond_to do |format|
      format.html do
        if @sign_in_activity.valid?
          sign_in @sign_in_activity.user, store: @sign_in_activity.remember_me?
          #remember_me :user
          redirect_to :admin_root
        else
          render :new
        end
      end
    end
  end

  def destroy
    sign_out current_user
    #forget_me :user
    respond_to do |format|
      format.html { redirect_to :admin_root }
    end
  end

  private
  def sign_in_params
    params.require(:session).permit(:email, :password, :remember_me)
  end
end