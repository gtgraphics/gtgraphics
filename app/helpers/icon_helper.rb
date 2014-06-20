module IconHelper
  # Bootstrap

  def caret(direction = :down)
    css = 'caret'
    css << "-#{direction}" if direction != :down
    content_tag :b, nil, class: css
  end

  # Font Awesome

  def icon(name, options = {})
    icon = FontAwesome::Icon.new(name, options)
    content_tag :i, nil, icon.tag_options
  end

  def icon_stack(options = {}, &block)
    icon_stack = FontAwesome::IconStack.new(options)
    content_tag :span, icon_stack.tag_options, &block
  end

  def append_icon(*args, &block)
    _labelled_icon(:append, nil, *args, &block)
  end

  def prepend_icon(*args, &block)
    _labelled_icon(:prepend, nil, *args, &block)
  end

  # Flags
  
  def flag_icon(locale, options = {})
    size = options.delete(:size) { 16 }
    options[:class] = "#{options[:class]} flag flag-#{size} flag-#{size}-#{locale}"
    options[:class] << ' flag-fw' if options.delete(:fixed_width)
    options[:class].strip!
    content_tag :i, nil, options
  end

  def append_flag_icon(*args, &block)
    _labelled_icon(:append, 'flag_', *args, &block)
  end

  def prepend_flag_icon(*args, &block)
    _labelled_icon(:prepend, 'flag_', *args, &block)
  end

  private
  def _labelled_icon(location, prefix, name, *args, &block)
    options = args.extract_options!
    caption = args.first
    caption ||= capture(&block) if block_given?

    caption_options = options.delete(:caption_html) { Hash.new }
    caption_options[:class] = (caption_options[:class].to_s.split << 'caption').uniq.join(' ')

    content_tag :span, class: "#{location}-#{prefix.to_s.dasherize}icon" do
      concat send("#{prefix}icon", name, options) if location == :prepend
      concat content_tag(:span, caption, caption_options) if caption.present?
      concat send("#{prefix}icon", name, options) if location == :append
    end
  end
end