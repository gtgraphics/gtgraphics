module ShopProvidersHelper
  def shop_provider_icon(name, options = {})
    options = options.reverse_merge(size: 16)
    size = options[:size]
    css = "shop shop-#{size} shop-#{size}-#{name.to_s.dasherize}"
    css << " shop-fw" if options[:fixed_width]
    content_tag :i, nil, class: css
  end
end