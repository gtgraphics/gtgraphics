class Admin::AccountsController < Admin::ApplicationController
  respond_to :html

  before_action :load_user

  breadcrumbs do |b|
    b.append translate('breadcrumbs.edit', model: translate('views.admin.account.breadcrumbs.account')), :edit_admin_account if action_name.in? %w(edit update edit_password update_password)
    b.append translate('breadcrumbs.edit', model: User.human_attribute_name(:password)), :edit_password_admin_account if action_name.in? %w(edit_password update_password)
  end

  def edit
    respond_with :admin, @user, template: 'admin/users/editor'
  end

  def update
    flash_for @user if @user.update(user_params)
    respond_with :admin, @user, template: 'admin/users/editor', location: :admin_account
  end

  def edit_password
    @change_password_activity = ChangePasswordActivity.new(user: @user)
    respond_with :admin, @user, template: 'admin/users/edit_password'
  end

  def update_password
    @change_password_activity = ChangePasswordActivity.new(user: @user)
    @change_password_activity.attributes = account_password_params
    if @change_password_activity.execute
      sign_in @user, bypass: true
      flash_for @user
      respond_to do |format|
        format.html { redirect_to [:admin, @user] }
      end
    else
      respond_to do |format|
        format.html { render 'admin/users/edit_password' }
      end
    end
  end

  def destroy
    @user.destroy
    flash_for @user
    respond_with :admin, @user, location: :root
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
  def account_password_params
    permitted_params = [:generate_password, :password, :password_confirmation]
    permitted_params << :current_password if @user.current?
    params.require(:user).permit(*permitted_params)
  end

  def account_preferences_params
    params.permit(:image_view_mode)
  end

  def load_user
    @user = User.find(current_user.id)
  end
end