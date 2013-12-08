class Admin::UsersController < Admin::ApplicationController
  respond_to :html

  before_action :load_user, only: %i(show edit update edit_password update_password destroy)

  breadcrumbs do |b|
    b.append User.model_name.human(count: 2), :admin_users
    b.append translate('breadcrumbs.new', model: User.model_name.human), :new_admin_user if action_name.in? %w(new create)
    b.append @user.full_name, [:admin, @user] if action_name.in? %w(show edit update)
    b.append translate('breadcrumbs.edit', model: User.model_name.human), [:edit, :admin, @user] if action_name.in? %w(edit update)
  end

  def index
    @users = User.all
    respond_with :admin, @users
  end

  def new
    @user = User.new
    respond_with :admin, @user
  end

  def create
    @user = User.create(create_user_params)
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
    respond_with :admin, @user
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

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale, :current_password, :password, :password_confirmation)
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end