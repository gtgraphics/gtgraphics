class Admin::UsersController < Admin::ApplicationController
  respond_to :html

  before_action :load_user, only: %i(show edit update edit_password update_password destroy)

  breadcrumbs do |b|
    b.append User.model_name.human(count: 2), :admin_users
    b.append @user.full_name, [:admin, @user] if @user
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
    @user = User.create(user_params)
    respond_with :admin, @user
  end

  def show
    respond_with :admin, @user
  end

  def edit
    respond_with :admin, @user
  end

  def update
    @user.update(user_params)
    respond_with :admin, @user
  end

  def edit_password
    respond_with :admin, @user
  end

  def update_password
    @user.update(user_password_params)
    respond_with :admin, @user, template: 'edit_password'
  end

  def destroy
    @user.destroy
    respond_with :admin, @user
  end

  private
  def load_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end