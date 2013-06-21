class UsersController < ApplicationController
  respond_to :html

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
    respond_with @users
  end

  def show
    respond_with @user
  end

  def new
    @user = User.new
    respond_with @user
  end

  def create
    @user = User.create(user_params)
    respond_with @user
  end

  def edit
    respond_with @user
  end

  def update
    @user.update(user_params)
    respond_with @user
  end

  def destroy
    @user.destroy
    respond_with @user
  end

  private
  def set_user
    @user = User.find_by_slug!(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name)
  end
end
