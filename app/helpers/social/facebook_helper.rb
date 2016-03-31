module Social::FacebookHelper
  def facebook_app_id
    facebook_config[:app_id]
  end

  def facebook_config
    @facebook_config ||= YAML.load_file(
      "#{Rails.root}/config/facebook.yml").deep_symbolize_keys
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
    options = options.reverse_merge(
      width: '100%', count: 5, colorscheme: :light, order_by: :reverse_time
    )
    content_tag :div, nil, class: 'fb-comments', data: {
      href: url,
      width: options[:width],
      numposts: options[:count],
      colorscheme: options[:colorscheme],
      order_by: options[:order_by]
    }
  end

  def facebook_like_button(url, options = {})
    options = options.reverse_merge(
      width: 200, style: :button_count, label: :like,
      show_faces: true, share_button: false
    )
    content_tag :div, nil, class: 'fb-like', data: {
      href: url,
      width: options[:width],
      layout: options[:style],
      action: options[:label],
      show_faces: options[:show_faces],
      share: options[:share_button]
    }
  end

  def facebook_page_url
    facebook_config[:page_url]
  end

  def facebook_site_like_button(options = {})
    facebook_like_button facebook_page_url,
                         style: :button_count, show_faces: false
  end
end
