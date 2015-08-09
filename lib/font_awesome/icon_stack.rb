module FontAwesome
  class IconStack < Iconish
    VALID_OPTIONS = %i(size)

    def initialize(options = {})
      @html_options = options.except(*VALID_OPTIONS)
      @options = options.slice(*VALID_OPTIONS)
    end

    protected

    def css_classes
      css = %w(fa-stack)
      set_size(css)
      css
    end
  end
end
