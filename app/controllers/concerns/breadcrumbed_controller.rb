module BreadcrumbedController
  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumb, :breadcrumbs
  end

  module ClassMethods
    protected
    def breadcrumb(*args)
      options = args.extract_options!
      case args.length
      when 1
        caption = -> { instance_variable_get("@#{args.first}").to_s }
        destination = -> { instance_variable_get("@#{args.first}") }
      when 2
        caption, destination = args
      else raise ArgumentError, 'invalid number of arguments'
      end
      before_action(options) do |controller|
        caption = controller.instance_exec(&caption) if caption.respond_to? :call
        destination = controller.instance_exec(&destination) if destination.respond_to? :call
        breadcrumb(caption, destination)
      end
    end
  end

  protected
  def breadcrumb(*args)
    case args.length
    when 1
      caption = instance_variable_get("@#{args.first}").to_s
      destination = instance_variable_get("@#{args.first}")
    when 2
      caption, destination = args
    else raise ArgumentError, 'invalid number of arguments'
    end
    breadcrumbs << Breadcrumb.new(breadcrumbs, caption, destination) unless caption.nil? or destination.nil?
  end

  def breadcrumbs
    @breadcrumbs ||= []
  end
end