module Page::RegionsHelper
  def render_region(label)
    raise Template::NotSupported.new(@page) unless @page.support_templates?
    region_definition = @region_definitions.find { |definition| definition.label == label.to_s }
    if region_definition
      region = @page.regions.find { |region| region.definition_id == region_definition.id }
      content_tag :div, region.body.html_safe, class: 'region' if region and region.body.present?
    else
      raise Template::RegionDefinition::NotFound.new(label, @page.template) if Rails.env.development?
    end
  end
end