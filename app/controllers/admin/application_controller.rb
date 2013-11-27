class Admin::ApplicationController < ApplicationController
  include BreadcrumbController

  before_action :authenticate_user!

  reset_breadcrumbs
  breadcrumbs do |b|
    b.append I18n.translate('breadcrumbs.home'), :admin_root
  end
end