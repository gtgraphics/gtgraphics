module FontAwesome
  class Iconish
    attr_reader :options, :html_options

    def tag_options
      css = (css_classes + @html_options[:class].to_s.split).uniq.join(' ')
      @html_options.merge(class: css)
    end

    protected

    def css_classes
      fail NotImplementedError
    end

    def set_size(css)
      return unless @options[:size]
      if @options[:size].in?([:large, :lg])
        css << 'fa-lg'
      else
        css << "fa-#{@options[:size]}x"
      end
    end
  end
end
