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

  def include_facebook_javascript_sdk
    if I18n.locale == :de
      locale = 'de_DE'
    else
      locale = 'en_US'
    end
    capture do
      concat content_tag(:div, nil, id: 'fb-root')
      js = javascript_tag <<-JAVASCRIPT.strip_heredoc
        (function(d, s, id) {
          var js, fjs = d.getElementsByTagName(s)[0];
          if (d.getElementById(id)) return;
          js = d.createElement(s); js.id = id;
          js.src = "//connect.facebook.net/#{locale}/sdk.js#xfbml=1&appId=#{facebook_app_id}&version=v2.0";
          fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));
      JAVASCRIPT
      concat js
    end
  end

  def facebook_comments(url, options = {})
    count = options.fetch(:count) { 5 }
    colorscheme = options.fetch(:colorscheme) { :light }
    width = options.fetch(:width) { '100%' }
    content_tag :div, nil, class: 'fb-comments', data: {
      href: url, numposts: count, colorscheme: colorscheme, width: width
    }
  end
end