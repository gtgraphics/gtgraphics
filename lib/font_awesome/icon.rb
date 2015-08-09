module FontAwesome
  class Icon < Iconish
    VALID_OPTIONS = :shape, :direction, :style, :outline, :spin, :size, :rotate,
                    :flip, :inverse, :border, :fixed_width

    attr_reader :name

    def initialize(name, options = {})
      @name = name
      @html_options = options.except(*VALID_OPTIONS)
      @options = options.slice(*VALID_OPTIONS).reverse_merge(
        border: false,
        fixed_width: false,
        inverse: false,
        outline: false,
        rotate: 0,
        spin: false
      )
    end

    protected

    def css_classes
      css = %w(fa)
      css << name_css
      set_size(css)
      set_fixed_width(css)
      set_transform(css)
      set_color(css)
      set_border(css)
      set_spin(css)
      css
    end

    private

    def name_css
      name_css = "fa-#{name.to_s.dasherize}"
      name_css << "-#{@options[:shape].to_s.dasherize}" if @options[:shape]
      name_css << '-o' if @options[:outline]
      if @options[:direction]
        name_css << "-#{@options[:direction].to_s.dasherize}"
      end
      name_css << "-#{@options[:style].to_s.dasherize}" if @options[:style]
      name_css
    end

    def set_border(css)
      css << 'fa-border' if @options[:border]
    end

    def set_color(css)
      css << 'fa-inverse' if @options[:inverse]
    end

    def set_fixed_width(css)
      css << 'fa-fw' if @options[:fixed_width]
    end

    def set_flip(css)
      return unless @options[:flip]
      if @options[:flip].to_sym.in? [:horizontal, :vertical]
        css << "fa-flip-#{@options[:flip]}"
      else
        fail ArgumentError, ':flip must be :horizontal or :vertical'
      end
    end

    def set_spin(css)
      css << 'fa-spin' if @options[:spin]
    end

    def set_transform(css)
      if @options[:rotate] && @options[:rotate] != 0
        css << "fa-rotate-#{@options[:rotate]}"
      end
    end
  end
end
