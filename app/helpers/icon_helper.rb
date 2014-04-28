module IconHelper
  # Bootstrap

  def caret(direction = :down)
    css = 'caret'
    css << "-#{direction}" if direction != :down
    content_tag :b, nil, class: css
  end

  # Font Awesome

  def icon(name, options = {})
    icon_class = "fa fa-#{name.to_s.dasherize}"
    if shape = options[:shape]
      icon_class << "-#{shape.to_s.dasherize}"
    end
    icon_class << '-o' if options[:outline]
    if direction = options[:direction]
      icon_class << "-#{direction.to_s.dasherize}"
    end
    icon_class << ' fa-spin' if options[:spin]
    if size = options[:size]
      if size == :large
        icon_class << ' fa-lg'
      else
        icon_class << " fa-#{size}x"
      end
    end
    icon_class << ' fa-inverse' if options[:inverse]
    if rotate = options[:rotate] and rotate != 0
      icon_class << " fa-rotate-#{rotate}"
    end
    if flip = options[:flip]
      icon_class << " fa-flip-#{flip}"
    end
    icon_class << ' fa-border' if options[:border]
    icon_class << ' fa-fw' if options[:fixed_width]
    icon_class << " #{options[:class]}" if options[:class]
    content_tag :i, nil, class: icon_class, style: options[:style]
  end

  def append_icon(*args, &block)
    _labelled_icon(:append, *args, &block)
  end

  def prepend_icon(*args, &block)
    _labelled_icon(:prepend, *args, &block)
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

  def append_flag_icon(*args, &block)
    _labelled_flag_icon(:append, *args, &block)
  end

  def prepend_flag_icon(*args, &block)
    _labelled_flag_icon(:prepend, *args, &block)
  end

  private
  def _labelled_icon(location, name, *args, &block)
    options = args.extract_options!
    caption = args.first
    caption ||= capture(&block) if block_given?
    raise ArgumentError, 'no text supplied' if caption.nil?

    caption_options = options.delete(:caption_html) { Hash.new }
    caption_options[:class] ||= ''
    caption_options[:class] << ' caption'
    caption_options[:class].strip!

    content_tag :span, class: "#{location}-icon" do
      concat icon(name, options) if location == :prepend
      concat content_tag(:span, caption, caption_options) if caption.present?
      concat icon(name, options) if location == :append
    end
  end

  def _labelled_flag_icon(location, locale, *args, &block)
    options = args.extract_options!
    caption = args.first
    caption ||= capture(&block) if block_given?
    raise ArgumentError, 'no text supplied' if caption.nil?

    caption_options = options.delete(:caption_html) { Hash.new }
    caption_options[:class] ||= ''
    caption_options[:class] << ' caption'
    caption_options[:class].strip!

    content_tag :span, class: "#{location}-flag-icon" do
      concat flag_icon(locale, options) if location == :prepend
      concat content_tag(:span, caption, caption_options) if caption.present?
      concat flag_icon(locale, options) if location == :append
    end
  end
end