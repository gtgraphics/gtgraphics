class Admin::ApplicationController < ApplicationController
  include BreadcrumbController

  authenticate_user

  reset_breadcrumbs
  breadcrumbs do |b|
    b.append I18n.translate('breadcrumbs.home'), :admin_root
  end
end