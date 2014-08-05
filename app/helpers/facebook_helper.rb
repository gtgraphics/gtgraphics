module FacebookHelper
  def facebook_app_id
    facebook_config[:app_id]
  end

  def facebook_config
    @@facebook_config ||= YAML.load_file("#{Rails.root}/config/facebook.yml").deep_symbolize_keys
  end

  def facebook_meta_tags
    admin_ids = facebook_config.fetch(:admins) { Array.new }.join(',')
    capture do
      concat tag(:meta, property: 'fb:app_id', content: facebook_app_id)
      concat tag(:meta, property: 'fb:admins', content: admin_ids)
    end
  end

  def facebook_sdk_anchor
    content_tag :div, nil, id: 'fb-root'
  end

  def facebook_comments(url, options = {})
    options = options.reverse_merge(count: 5, colorscheme: :light, width: '100%', order_by: :reverse_time)
    content_tag :div, nil, class: 'fb-comments', data: {
      href: url,
      numposts: options[:count],
      colorscheme: options[:colorscheme],
      order_by: options[:order_by],
      width: options[:width]
    }
  end
end