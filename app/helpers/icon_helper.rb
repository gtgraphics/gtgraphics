module IconHelper
  # Bootstrap

  def caret(direction = :down)
    css = 'caret'
    css << "-#{direction}" if direction != :down
    content_tag :b, nil, class: css
  end

  # Font Awesome

  def icon(name, options = {})
    FontAwesome::Icon.new(self, options.merge(name: name)).render
  end

  def append_icon(*args, &block)
    _labelled_icon(:append, nil, *args, &block)
  end

  def prepend_icon(*args, &block)
    _labelled_icon(:prepend, nil, *args, &block)
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
    raise ArgumentError, 'no text supplied' if caption.nil?

    caption_options = options.delete(:caption_html) { Hash.new }
    caption_options[:class] ||= ''
    caption_options[:class] << ' caption'
    caption_options[:class].strip!

    content_tag :span, class: "#{location}-#{prefix.to_s.dasherize}icon" do
      concat send("#{prefix}icon", name, options) if location == :prepend
      concat content_tag(:span, caption, caption_options) if caption.present?
      concat send("#{prefix}icon", name, options) if location == :append
    end
  end
end