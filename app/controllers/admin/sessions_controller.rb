class Admin::SessionsController < Admin::ApplicationController
  skip_authentication only: [:new, :create]

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
          user = @sign_in_activity.user
          sign_in user, permanent: @sign_in_activity.permanent?
          user.track_sign_in!(request.ip)
          redirect_to flash[:after_sign_in_path] || :admin_root
        else
          render :new
        end
      end
    end
  end

  def destroy
    sign_out
    respond_to do |format|
      format.html { redirect_to flash[:after_sign_out_path] || :admin_root }
    end
  end

  private
  def sign_in_params
    params.require(:session).permit(:email, :password, :permanent)
  end
end