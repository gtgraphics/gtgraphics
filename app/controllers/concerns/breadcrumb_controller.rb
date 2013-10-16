module BreadcrumbController
  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumbs
  end

  module ClassMethods
    protected
    def breadcrumb(caption, destination, options = {})
      before_action(options) do |controller|
        controller.breadcrumbs.append(caption, destination)
      end
    end

    def breadcrumbs(options = {}, &block)
      raise ArgumentError, 'no block given' unless block_given?
      before_action(options) do |controller|
        controller.instance_exec(breadcrumbs, controller, &block)
      end
    end
  end

  protected
  def breadcrumbs
    @breadcrumbs ||= Breadcrumb::Collection.new(self)
  end
end