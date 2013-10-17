class Admin::ApplicationController < ApplicationController
  include BreadcrumbController

  reset_breadcrumbs
  breadcrumb I18n.translate('breadcrumbs.home'), :admin_root
end