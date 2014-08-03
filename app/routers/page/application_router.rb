class Page::ApplicationRouter
  attr_reader :page_type

  def initialize(page_type)
    @page_type = page_type
    declare
  end

  def action_definitions
    @action_definitions ||= {}
  end

  def insert(map)
    map.instance_exec(self) do |router|
      constraints Routing::Cms::PageConstraint.new(router.page_type) do
        router.action_definitions.each do |action_name, options_collection|
          options_collection.each do |options|
            options = options.reverse_merge(controller: router.controller_name, action: action_name, via: :get)
            if action_name == :show
              match '(*path)(.:format)', options.reverse_merge(as: router.resource_name)
            else
              match "(*path/)#{action_name}(.:format)", options.reverse_merge(as: "#{action_name}_#{router.resource_name}")
            end
          end
        end
      end
    end
  end

  def controller_name
    page_type.underscore.pluralize
  end

  def resource_name
    page_type.demodulize.underscore
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