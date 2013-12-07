class Admin::AccountsController < Admin::ApplicationController
  respond_to :html

  def show
    respond_with :admin, @user
  end

  def edit
    respond_with :admin, @user
  end

  def update
    respond_with :admin, @user, location: :admin_account
  end

  def destroy
    respond_with :admin, @user, location: :root
  end

  private
  def load_user
    @user = User.find(current_user.id)
  end
end