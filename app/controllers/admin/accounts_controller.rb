class Admin::AccountsController < Admin::ApplicationController
  respond_to :html

  before_action :load_user

  breadcrumbs do |b|
    if action_name.in? %w(edit update edit_password update_password)
      b.append translate('breadcrumbs.edit', model: translate('views.admin.account.breadcrumbs.account')), :edit_admin_account
    end
    if action_name.in? %w(edit_password update_password)
      b.append translate('breadcrumbs.edit', model: User.human_attribute_name(:password)), :edit_password_admin_account
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to action: :edit }
    end
  end

  def edit
    @user_update_form = Admin::User::AccountUpdateForm.new
    @user_update_form.user = @user
    respond_to do |format|
      format.html { render 'admin/users/edit' }
    end
  end

  def update
    @user_update_form = Admin::User::AccountUpdateForm.new
    @user_update_form.user = @user
    @user_update_form.attributes = user_account_update_params
    if @user_update_form.execute
      flash_for @user_update_form.user, :updated
      respond_to do |format|
        format.html { redirect_to :edit_admin_account }
      end
    else
      respond_to do |format|
        format.html { render 'admin/users/edit' }
      end
    end
  end

  def update_preferences
    account_preferences_params.each do |key, value|
      @user.preferences[key] = value
    end
    @user.save!
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end 

  private
  def account_preferences_params
    params.permit(:image_view_mode)
  end

  def load_user
    @user = User.find(current_user.id)
  end

  def user_account_update_params
    params.require(:user_update).permit(
      :first_name, :last_name, :email, :preferred_locale,
      :current_password, :reset_password, :generate_password, :password, :password_confirmation
    )
  end
end