module PagesHelper
  def render_content(content)
    template = Liquid::Template.parse(content)
    template.render(@page.to_liquid).html_safe
  end

  def render_region(label)
    raise Page::Region::NotSupported.new(@page) unless @page.supports_regions?
    if can? :update, @page and region_definition = @region_definitions.find { |definition| definition.label == label.to_s }
      region = @page.regions.find_by(definition: region_definition)
      content = render_content(region.try(:body))
      if editing?
        content_tag :div, content, class: 'region well', data: { region: label, url: admin_page_region_path(@page, label) }
      else
        content
      end
    else
      raise Page::Region::NotFound.new(label, @page.template) if Rails.env.development?
    end
  end
end