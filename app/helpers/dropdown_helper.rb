module DropdownHelper
  def dropdown(label, options = {}, &block)
    html_options = options.dup

    url = html_options.delete(:href) { '#' }
    right = html_options.delete(:right) { false }

    html_options[:id] ||= "dropdown_#{microtimestamp}"
    html_options[:class] = ['dropdown-toggle', html_options[:class]].compact
    html_options.merge!(data: { toggle: 'dropdown' }, 'aria-haspopup' => true)

    menu_html_options = html_options.delete(:menu_html) { Hash.new }
    menu_html_options[:class] = ['dropdown-menu',
                                 right ? 'dropdown-menu-right' : nil,
                                 menu_html_options[:class]].compact
    menu_html_options.merge!(role: 'menu',
                             'aria-labelledby' => html_options[:id])

    capture do
      link = link_to url, html_options do
        content_tag :div do
          concat label
          concat caret
        end
      end
      concat link
      concat content_tag(:ul, capture(&block), menu_html_options)
    end
  end
end
