module IconHelper
  def append_icon(icon_name, caption = nil, &block)
    caption ||= capture(&block) if block_given?
    raise ArgumentError, 'no text supplied' if caption.nil?
    content_tag :span, class: 'append-icon' do
      html = ""
      html << content_tag(:span, caption, class: 'caption') if caption.present?
      html << icon(icon_name)
      html.html_safe
    end
  end

  def icon(icon_name)
    content_tag :i, nil, class: "icon-#{icon_name.to_s.dasherize}"
  end

  def prepend_icon(icon_name, caption = nil, &block)
    caption ||= capture(&block) if block_given?
    raise ArgumentError, 'no text supplied' if caption.nil?
    content_tag :span, class: 'prepend-icon' do
      html = icon(icon_name)
      html << content_tag(:span, caption, class: 'caption') if caption.present?
      html.html_safe
    end
  end

  # Flags
  def flag_icon(locale, options = {})
    size = options.fetch(:size, 16)
    options = options.reverse_merge(alt: translate(locale, scope: :languages)).merge(width: size, height: size)
    options[:class] ||= ""
    options[:class] << " flag"
    options[:class].strip!
    image_tag("flags/#{size}/#{locale}.png", options)
  end
end