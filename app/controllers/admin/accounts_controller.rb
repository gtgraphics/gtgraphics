class Admin::AccountsController < Admin::ApplicationController
  respond_to :html

  before_action :load_user

  breadcrumbs do |b|
    b.append translate('views.admin.account.breadcrumbs.my_account'), :admin_account
    b.append translate('breadcrumbs.edit', model: translate('views.admin.account.breadcrumbs.account')), :edit_admin_account if action_name.in? %w(edit update edit_password update_password)
    b.append translate('breadcrumbs.edit', model: User.human_attribute_name(:password)), :edit_password_admin_account if action_name.in? %w(edit_password update_password)
  end

  def show
    respond_with :admin, @user, template: 'admin/users/show'
  end

  def edit
    respond_with :admin, @user, template: 'admin/users/edit'
  end

  def update
    respond_with :admin, @user, template: 'admin/users/edit', location: :admin_account
  end

  def edit_password
    respond_with :admin, @user, template: 'admin/users/edit_password'
  end

  def update_password
    if @user.update_with_password(user_password_params)
      sign_in @user, bypass: true
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
    respond_with :admin, @user, location: :root
  end

  private
  def load_user
    @user = User.find(current_user.id)
  end
end