class Admin::ApplicationController < ApplicationController
  include Admin::RouteHelper

  skip_maintenance_check

  authenticate

  reset_breadcrumbs
  breadcrumbs do |b|
    b.append I18n.translate('breadcrumbs.home'), :admin_root
  end
end