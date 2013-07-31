class Admin::ApplicationController < ApplicationController
  #include BreadcrumbedController

  def self.breadcrumbs(options = {}, &block)
    raise ArgumentError, 'no block given' unless block_given?
    before_action do |controller|
      breadcrumbs = BreadcrumbCollection.new(self, options)
      yield(breadcrumbs)
      controller.instance_variable_set("@breadcrumbs", breadcrumbs)
    end
  end

  attr_reader :breadcrumbs
  protected :breadcrumbs
  helper_method :breadcrumbs
end