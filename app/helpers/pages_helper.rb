module PagesHelper
  def render_content(content)
    template = Liquid::Template.parse(content)
    template.render(@page.to_liquid).html_safe
  end

  def render_region(name)
    if region_definition = @page.template.region_definitions.find_by(label: name)
      if can? :update, @page
        data = { region: name, url: admin_page_path(@page), method: :patch }        
      end
      content_tag :div, class: 'region well', data: data do
        if region = @page.regions.find_by(definition_id: region_definition.id)
          render_content(region.body)
        end
      end
    else
      raise Region::NotFound.new(name, @page.template) if Rails.env.development?
      ""
    end
  end
end