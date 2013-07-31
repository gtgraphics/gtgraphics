class Admin::ApplicationController < ApplicationController
  include BreadcrumbedController

  breadcrumb 'Root', '/'
end