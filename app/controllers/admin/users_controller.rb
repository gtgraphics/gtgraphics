class Admin::UsersController < Admin::ApplicationController
  respond_to :html

  before_action :load_user, only: %i(show edit update edit_password
                                     update_password destroy)
  before_action :redirect_to_account_page_if_current_user

  breadcrumbs do |b|
    b.append User.model_name.human(count: 2), :admin_users
    if action_name.in? %w(new create)
      b.append translate('breadcrumbs.new', model: User.model_name.human), :new_admin_user
    end
    if action_name.in? %w(edit update edit_password update_password)
      b.append translate('breadcrumbs.edit', model: User.model_name.human), [:edit, :admin, @user]
    end
    if action_name.in? %w(edit_password update_password)
      b.append translate('breadcrumbs.edit', model: User.human_attribute_name(:password)), [:edit_password, :admin, @user]
    end
  end

  def index
    @current_users = User.current_users
    @users = User.all.uniq
    @user_search = @users.search(params[:search])
    if @user_search.sorts.empty?
      @user_search.sorts = ['first_name asc', 'last_name asc']
    end
    @users = @user_search.result.page(params[:page])
    respond_with :admin, @users
  end

  def new
    @user_registration_form = Admin::User::RegistrationForm.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @user_registration_form = Admin::User::RegistrationForm.new(
      user_registration_params)
    if @user_registration_form.submit
      flash_for @user_registration_form.user, :created
      respond_to do |format|
        format.html { redirect_to :admin_users }
      end
    else
      respond_to do |format|
        format.html { render :new }
      end
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to [:edit, :admin, @user] }
    end
  end

  def edit
    @user_update_form = Admin::User::UpdateForm.new
    @user_update_form.user = @user
    respond_to do |format|
      format.html
    end
  end

  def update
    @user_update_form = Admin::User::UpdateForm.new
    @user_update_form.user = @user
    @user_update_form.attributes = user_update_params
    if @user_update_form.submit
      flash_for @user_update_form.user, :updated
      respond_to do |format|
        format.html { redirect_to :admin_users }
      end
    else
      respond_to do |format|
        format.html { render :edit }
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

  def redirect_to_account_page_if_current_user
    return if @user.nil? || @user != current_user
    redirect_to params.slice(:action).merge(controller: 'accounts')
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email,
                                 :preferred_locale)
  end

  def user_registration_params
    params.require(:user_registration).permit(
      :first_name, :last_name, :email, :preferred_locale, :twitter_username,
      :generate_password, :password, :password_confirmation
    )
  end

  def user_update_params
    params.require(:user_update).permit(
      :first_name, :last_name, :email, :preferred_locale, :twitter_username,
      :reset_password, :generate_password, :password, :password_confirmation,
      :photo, :remove_photo
    )
  end
end
