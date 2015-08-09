module Router
  module UrlHelpers
    module_function

    def root_path(options = {})
      page_path(Page.root, options)
    end

    def root_url(options = {})
      page_url(Page.root, options)
    end

    def page_path(*args)
      options = args.extract_options!.merge(only_path: true)
      page_url(*args, options)
    end

    def page_url(*args)
      options = args.extract_options!.dup
      unless options[:only_path]
        if respond_to?(:request) && !request.nil?
          options[:protocol] = request.protocol
          options[:host] = request.host
          options[:port] = request.port
        end
        if respond_to?(:default_url_options)
          options.reverse_merge!(default_url_options || {})
        elsif respond_to?(:mailer)
          options.reverse_merge!(mailer.default_url_options || {})
        elsif respond_to?(:controller)
          options.reverse_merge!(controller.default_url_options || {})
        end
      end
      UrlBuilder.new(*args, options).to_s
    end
  end
end
