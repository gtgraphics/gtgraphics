class Admin::ApplicationController < ApplicationController
  include BreadcrumbController

  breadcrumb I18n.translate('breadcrumbs.home'), :admin_root
end