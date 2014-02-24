module PagesHelper
  def render_region(label)
    raise Template::RegionDefinition::NotSupported.new(@page.template) unless @page.supports_regions?
    if region_definition = @region_definitions.find { |definition| definition.label == label.to_s }
      region = @page.regions.find_by(definition: region_definition)
      attributes = @page.to_liquid.merge(attributes.deep_stringify_keys)
      content = liquify(region.try(:body), attributes)
      if editing? and can? :update, @page
        content_tag :div, content, class: 'region well', data: { region: label, url: admin_page_region_path(@page, label) }
      else
        content
      end
    else
      raise Template::RegionDefinition::NotFound.new(label, @page.template) if Rails.env.development?
    end
  end
end