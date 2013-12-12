class Admin::ApplicationController < ApplicationController
  include BreadcrumbController

  before_action :authenticate_user!

  # TODO REMOVE
  #def current_user
  #  @user ||= User.find_by(email: 'tobias.casper@gmail.com')
  #end

  reset_breadcrumbs
  breadcrumbs do |b|
    b.append I18n.translate('breadcrumbs.home'), :admin_root
  end
end