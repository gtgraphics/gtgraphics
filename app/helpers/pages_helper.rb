module PagesHelper
  def render_content(content)
    template = Liquid::Template.parse(content)
    template.render(@page.to_liquid).html_safe
  end

  def render_region(name)
    raise Page::Region::NotSupported.new(@page) unless @page.supports_regions?
    if region_definition = @region_definitions.find { |definition| definition.label == name.to_s }
      if can? :update, @page
        data = { region: name, url: update_region_admin_page_path(@page) }
      end
      region = @page.regions.find_by(definition: region_definition)
      if editing?
        content_tag :div, class: 'region well', data: data do
          region.try(:body)
        end
      else
        render_content(region.try(:body))
      end
    else
      raise Page::Region::NotFound.new(name, @page.template) if Rails.env.development?
    end
  end
end