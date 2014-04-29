class FontAwesome::Icon < Presenter
  default shape: nil, direction: nil, spin: false, outline: false, size: nil,
          rotate: 0, flip: nil, inverse: false, border: false, fixed_width: false

  def render
    css = ['fa']

    name_css = "fa-#{name.to_s.dasherize}"
    name_css << "-#{shape.to_s.dasherize}" if shape
    name_css << '-o' if outline
    name_css << "-#{direction.to_s.dasherize}" if direction
    css << name_css

    css << 'fa-spin' if spin
    if size
      if size == :large
        css << 'fa-lg'
      else
        css << "fa-#{size}x"
      end
    end
    css << 'fa-inverse' if inverse
    css << "fa-rotate-#{rotate}" if rotate and rotate != 0
    css << "fa-flip-#{flip}" if flip
    css << 'fa-border' if border
    css << 'fa-fw' if fixed_width
    css += local_assigns[:class].to_s.split
    css.uniq!

    content_tag :i, nil, class: css.join(' '), style: css
  end
end