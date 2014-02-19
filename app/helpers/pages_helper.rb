module PagesHelper
  def render_content(content)
    template = Liquid::Template.parse(content)
    template.render(@page.to_liquid).html_safe
  end

  def render_region(name)
    raise Page::Region::NotSupported.new(@page) unless @page.supports_regions?
    if region_definition = @region_definitions.find { |definition| definition.label == name.to_s }
      if can? :update, @page
        data = { region: name, url: admin_page_path(@page), method: :patch }        
      end
      content_tag :div, class: 'region well', data: data do
        if region = @page.regions.find_by(definition: region_definition)
          render_content(region.body)
        end
      end
    else
      raise Page::Region::NotFound.new(name, @page.template) if Rails.env.development?
    end
  end
end