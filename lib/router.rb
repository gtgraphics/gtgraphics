module Router
  %w(controller_adapter error_handler locale_constraint middleware parser
     path subroute url_builder url_generation_error url_helpers).each do |file|
    autoload file.camelize.to_sym, "router/#{file}"
  end
end
