module FacebookResourcePresenter
  extend ActiveSupport::Concern

  def facebook_uri
    raise NotImplementedError, 'no Facebook URI defined'
  end

  def facebook_comments(options = {})
    options = options.reverse_merge(width: '100%', count: 5, colorscheme: :light, order_by: :reverse_time)
    content_tag :div, nil, class: 'fb-comments', data: {
      href: facebook_uri,
      width: options[:width],
      numposts: options[:count],
      colorscheme: options[:colorscheme],
      order_by: options[:order_by]
    }
  end

  def facebook_like_button(options = {})
    options = options.reverse_merge(width: '100%', style: :standard, label: :like, 
                                    show_faces: true, share_button: false)
    content_tag :div, nil, class: 'fb-like', data: {
      href: facebook_uri,
      width: options[:width],
      layout: options[:style],
      action: options[:label],
      show_faces: options[:show_faces],
      share: options[:share_button]
    }
  end
end