class Routing::Page
  ACTION_DEFAULTS = { via: :get }

  attr_reader :page_type

  def initialize(page_type)
    @page_type = page_type
    declare
  end

  def self.insert(mapper)
    ::Page::EMBEDDABLE_TYPES.each do |embeddable_type|
      begin
        "Routing::#{embeddable_type}".constantize.new(embeddable_type).insert(mapper)
      rescue NameError
        Rails.logger.warn "Routing::#{embeddable_type} could not be found. Please create a routing declaration for the resource."
      end
    end
  end

  def controller_name
    resource_name.to_s.pluralize
  end

  def action_definitions
    @action_definitions ||= {}
  end

  def insert(mapper)
    mapper.instance_exec(self) do |router|
      constraints Routing::PageConstraint.new(router.page_type) do
        router.action_definitions.each do |action_name, options_collection|
          options_collection.each do |options|
            options = options.reverse_merge(controller: router.controller_name, action: action_name, via: :get)
            if action_name == :show
              match '*path(.:format)', options.reverse_merge(as: router.resource_name)
            else
              match "*path/#{action_name}(.:format)", options.reverse_merge(as: "#{action_name}_#{router.resource_name}")
            end
          end
        end
      end
      constraints Routing::RootPageConstraint.new(router.page_type) do
        router.action_definitions.each do |action_name, options_collection|
          options_collection.each do |option|
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
  end

  def resource_class
    page_type.constantize
  end

  def resource_name
    resource_class.config.routing_resource_name
  end

  protected
  def root(options = {})
    match :show, options.reverse_merge(via: :get)
  end
  
  %w(get post put patch delete).each do |verb|
    class_eval <<-RUBY
      def #{verb}(action_name, options = {})
        options = options.merge(via: :#{verb})
        match(action_name, options)
      end
    RUBY
  end

  def match(action_name, options = {})
    action_definitions[action_name] ||= []
    action_definitions[action_name] << options
  end

  def declare
    root
  end
end