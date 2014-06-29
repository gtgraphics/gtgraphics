class FontAwesome::Iconish
  attr_reader :options, :html_options

  def tag_options
    css = (css_classes + @html_options[:class].to_s.split).uniq.join(' ')
    @html_options.merge(class: css)
  end

  protected
  def css_classes
    raise NotImplementedError
  end

  def set_size(css)
    css << (@options[:size].in?([:large, :lg]) ? 'fa-lg' : "fa-#{@options[:size]}x") if @options[:size]
  end
end