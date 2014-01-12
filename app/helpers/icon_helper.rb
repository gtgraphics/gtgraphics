module IconHelper
  # Bootstrap

  def caret
    content_tag :b, nil, class: 'caret'
  end

  # Font Awesome

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

  def append_icon(name, *args, &block)
    options = args.extract_options!
    caption = args.first
    caption ||= capture(&block) if block_given?
    raise ArgumentError, 'no text supplied' if caption.nil?

    caption_options = options.delete(:caption_html) { Hash.new }
    caption_options[:class] ||= ''
    caption_options[:class] << ' caption'
    caption_options[:class].strip!

    content_tag :span, class: 'append-icon' do
      html = ""
      html << content_tag(:span, caption, caption_options) if caption.present?
      html << icon(name, options)
      html.html_safe
    end
  end

  def prepend_icon(name, *args, &block)
    options = args.extract_options!
    caption = args.first
    caption ||= capture(&block) if block_given?
    raise ArgumentError, 'no text supplied' if caption.nil?

    caption_options = options.delete(:caption_html) { Hash.new }
    caption_options[:class] ||= ''
    caption_options[:class] << ' caption'
    caption_options[:class].strip!

    content_tag :span, class: 'prepend-icon' do
      html = icon(name, options)
      html << content_tag(:span, caption, caption_options) if caption.present?
      html.html_safe
    end
  end

  # Flags
  
  def flag_icon(locale, options = {})
    size = options.fetch(:size, 16)
    options = options.reverse_merge(alt: translate(locale, scope: :languages)).merge(width: size, height: size)
    options[:class] ||= ""
    options[:class] << " flag-icon img-circle"
    options[:class].strip!
    image_tag("flags/#{size}/#{locale}.png", options)
  end

  def append_flag_icon(locale, *args, &block)
    options = args.extract_options!
    caption = args.first
    caption ||= capture(&block) if block_given?
    raise ArgumentError, 'no text supplied' if caption.nil?

    caption_options = options.delete(:caption_html) { Hash.new }
    caption_options[:class] ||= ''
    caption_options[:class] << ' caption'
    caption_options[:class].strip!

    content_tag :span, class: 'append-flag-icon' do
      html = ""
      html << content_tag(:span, caption, caption_options) if caption.present?
      html << flag_icon(locale, options)
      html.html_safe
    end
  end

  def prepend_flag_icon(locale, *args, &block)
    options = args.extract_options!
    caption = args.first
    caption ||= capture(&block) if block_given?
    raise ArgumentError, 'no text supplied' if caption.nil?

    caption_options = options.delete(:caption_html) { Hash.new }
    caption_options[:class] ||= ''
    caption_options[:class] << ' caption'
    caption_options[:class].strip!

    content_tag :span, class: 'prepend-flag-icon' do
      html = flag_icon(locale, options)
      html << content_tag(:span, caption, caption_options) if caption.present?
      html.html_safe
    end
  end
end