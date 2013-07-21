ActiveSupport.on_load(:action_view) do
  Haml::Template.options[:attr_wrapper] = '"'
  Haml::Template.options[:format] = :html5
  Haml::Template.options[:remove_whitespace] = true unless Rails.env.development?
end