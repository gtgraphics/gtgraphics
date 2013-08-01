class Admin::ApplicationController < ApplicationController
  include BreadcrumbedController

  breadcrumb I18n.translate('breadcrumbs.home'), :admin_root
end