module GravatarHelper
  def gravatar_image_tag(email, options = {})
    html_options = options.except(*Gravatar::VALID_OPTIONS).deep_dup
    html_options[:alt] ||= email
    html_options[:class] = ['gravatar', *html_options[:class]].compact

    url_options = options.slice(*Gravatar::VALID_OPTIONS).reverse_merge(secure: request.ssl?)
    url_options.reverse_merge!(Gravatar::DEFAULTS)
    size = url_options[:size]
    html_options.reverse_merge!(width: size, height: size) if size

    image_tag gravatar_image_url(email, url_options), html_options
  end

  def gravatar_image_url(email, options = {})
    Gravatar.new(email, options.reverse_merge(secure: request.ssl?)).url
  end
end