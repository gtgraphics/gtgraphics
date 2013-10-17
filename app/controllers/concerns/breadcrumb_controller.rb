module BreadcrumbController
  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumbs, :breadcrumb_item_path, :breadcrumb_item_url
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

    def reset_breadcrumbs(options = {})
      before_action(options) do |controller|
        controller.breadcrumbs.clear
      end
    end
  end

  protected
  def breadcrumbs
    @breadcrumbs ||= Breadcrumb::Collection.new(self)
  end

  private
  def breadcrumb_item_path(breadcrumb_item, options = {})
    breadcrumb_item.path
  end

  def breadcrumb_item_url(breadcrumb_item, options = {})
    breadcrumb_item.url
  end
end