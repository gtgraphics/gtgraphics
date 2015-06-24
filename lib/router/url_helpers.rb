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
      if respond_to?(:request)
        options[:protocol] = request.protocol
        options[:host] = request.host
        options[:port] = request.port
      end
      if respond_to?(:default_url_options)
        options.reverse_merge!(default_url_options)
      end
      UrlBuilder.new(*args, options).to_s
    end
  end
end
