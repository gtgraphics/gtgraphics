class Routing::Page
  def self.draw(routes)
    ::Page::EMBEDDABLE_TYPES.each do |embeddable_type|
      begin
        "Routing::#{embeddable_type}".constantize.new(embeddable_type).draw(routes)
      rescue NameError
        Rails.logger.warn "Routing::#{embeddable_type} could not be found. Please create a routing declaration for the resource."
      end
    end
  end

  ACTION_DEFAULTS = { via: :get }

  attr_reader :page_type

  def initialize(page_type)
    @page_type = page_type
    declare
  end

  def controller_name
    resource_name.to_s.pluralize
  end

  def action_definitions
    @action_definitions ||= {}
  end

  def draw(routes)
    routes.instance_exec(self) do |router|
      scope constraints: Routing::PageConstraint.new(router.page_type) do
        router.action_definitions.each do |action_name, options|
          options = options.reverse_merge(controller: router.controller_name, action: action_name, via: :get)
          if action_name == :show
            match '*path(.:format)', options.reverse_merge(as: router.resource_name)
          else
            match "*path/#{action_name}(.:format)", options.reverse_merge(as: "#{action_name}_#{router.resource_name}")
          end
        end
      end
      scope constraints: Routing::RootPageConstraint.new(router.page_type) do
        router.action_definitions.each do |action_name, options|
          options = options.reverse_merge(controller: router.controller_name, action: action_name, via: :get).merge(as: nil)
          if action_name == :show
            root options.reverse_merge(as: "#{router.resource_name}_root")
          else
            match "#{action_name}(.:format)", options.reverse_merge(as: "#{action_name}_#{router.resource_name}_root")
          end
        end
      end
    end
  end

  def resource_class
    page_type.constantize
  end

  def resource_name
    resource_class.resource_name
  end

  protected
  def action(name, options = {})
    action_definitions[name] = options.reverse_merge(ACTION_DEFAULTS)
  end

  def declare
    raise NotImplemented, "#{self.class.name}#declare must be overridden in subclasses"
  end
end