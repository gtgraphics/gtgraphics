module PagesHelper
  def render_region(name)
    content_tag :div, class: 'region', data: { region: name } do
      (@page.contents || {}).fetch(name, '').html_safe
    end
  end
end