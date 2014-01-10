ActiveSupport.on_load(:action_view) do
  Haml::Template.options[:attr_wrapper] = '"'
  Haml::Template.options[:format] = :html5
end