class FontAwesome::IconStack < FontAwesome::Iconish
  VALID_OPTIONS = [:size]

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