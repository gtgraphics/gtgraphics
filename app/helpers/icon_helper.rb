module IconHelper
  def append_icon(name, *args, &block)
    options = args.extract_options!
    caption = args.first
    caption ||= capture(&block) if block_given?
    raise ArgumentError, 'no text supplied' if caption.nil?
    content_tag :span, class: 'append-icon' do
      html = ""
      html << content_tag(:span, caption, class: 'caption') if caption.present?
      html << icon(name, options)
      html.html_safe
    end
  end

  def icon(name, options = {})
    icon_class = "fa fa-#{name.to_s.dasherize}"
    if shape = options[:shape]
      icon_class << "-#{shape.to_s.dasherize}"
    end
    icon_class << "-o" if options[:outline]
    if direction = options[:direction]
      icon_class << "-#{direction.to_s.dasherize}"
    end
    icon_class << " fa-spin" if options[:spin]
    content_tag :i, nil, class: icon_class
  end

  def prepend_icon(name, *args, &block)
    options = args.extract_options!
    caption = args.first
    caption ||= capture(&block) if block_given?
    raise ArgumentError, 'no text supplied' if caption.nil?
    content_tag :span, class: 'prepend-icon' do
      html = icon(name, options)
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