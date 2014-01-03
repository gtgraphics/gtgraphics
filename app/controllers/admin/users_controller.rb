class Admin::UsersController < Admin::ApplicationController
  respond_to :html

  before_action :load_user, only: %i(show edit update edit_password update_password destroy)
  #before_action :redirect_if_current_user

  breadcrumbs do |b|
    b.append User.model_name.human(count: 2), :admin_users
    b.append translate('breadcrumbs.new', model: User.model_name.human), :new_admin_user if action_name.in? %w(new create)
    b.append @user.full_name, [:admin, @user] if action_name.in? %w(show edit update)
    b.append translate('breadcrumbs.edit', model: User.model_name.human), [:edit, :admin, @user] if action_name.in? %w(edit update edit_password update_password)
    b.append translate('breadcrumbs.edit', model: User.human_attribute_name(:password)), [:edit_password, :admin, @user] if action_name.in? %w(edit_password update_password)
  end

  def index
    @users = User.sort(params[:sort], params[:direction]).page(params[:page])
    respond_with :admin, @users
  end

  def new
    @user = User.new
    respond_with :admin, @user
  end

  def create
    @user = User.create(create_user_params)
    flash_for @user
    respond_with :admin, @user
  end

  def show
    respond_with :admin, @user
  end

  def edit
    respond_with :admin, @user
  end

  def update
    @user.update(update_user_params)
    flash_for @user
    respond_with :admin, @user
  end

  def edit_password
    respond_with :admin, @user
  end

  def update_password
    # TODO Make activity out of it
    if @user.current?
      saved = @user.update_with_password(account_password_params)
    else
      saved = @user.update(user_password_params)
    end
    if saved
      sign_in @user, bypass: true if @user.current?
      respond_to do |format|
        format.html { redirect_to [:admin, @user] }
      end
    else
      respond_to do |format|
        format.html { render :edit_password }
      end
    end
  end

  def destroy
    @user.destroy
    respond_with :admin, @user
  end

  private
  def load_user
    @user = User.find(params[:id])
  end

  def create_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale, :generate_password, :password, :password_confirmation)
  end

  def redirect_if_current_user
    redirect_to params.slice(:action).merge(controller: 'accounts') if @user and @user.current?
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale, :current_password, :password, :password_confirmation)
  end

  def user_password_params
    params.require(:user).permit(:generate_password, :password, :password_confirmation)
  end

  def account_password_params
    params.require(:user).permit(:current_password, :generate_password, :password, :password_confirmation)
  end
end