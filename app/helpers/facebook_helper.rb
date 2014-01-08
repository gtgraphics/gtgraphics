module FacebookHelper
  def facebook_config
    @@facebook_config ||= YAML.load_file("#{Rails.root}/config/facebook.yml").deep_symbolize_keys
  end

  def facebook_meta_tags
    tag(:meta, property: 'fb:app_id', content: facebook_config[:app_id]) <<
    "\n" << 
    tag(:meta, property: 'fb:admins', content: facebook_config.fetch(:admins, []).join(','))
  end
end