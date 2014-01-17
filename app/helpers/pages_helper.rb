module PagesHelper
  def render_region(name)
    #@page.region_labels.include?(name.to_s)
    content_tag :div, class: 'region well', data: { region: name } do
      #(@page.contents || {}).fetch(name, '').html_safe
      content = name.to_s << @page.inspect
      render_page_content(content)
    end
  end

  def render_page_content(content)
    template = Liquid::Template.parse(content)
    template.render(@page.to_liquid).html_safe
  end
end