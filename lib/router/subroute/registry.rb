module Router
  module Subroute
    class Registry
      attr_reader :controller, :definitions

      def initialize(controller)
        @controller = controller
        @definitions = controller.subroutes
      end

      def match(*args)
        options = args.extract_options!
        path = args.first.presence
        definitions << Definition.new(controller, path, options)
      end

      %i(get post patch put delete head).each do |request_method|
        define_method(request_method) do |*args|
          options = args.extract_options!.merge(via: request_method)
          match(*args, options)
        end
      end
    end
  end
end
