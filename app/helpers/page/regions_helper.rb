module Page::RegionsHelper
  def region_content_for?(label)
    @page.check_template_support!
    region_definition = @region_definitions.find { |definition| definition.label == label.to_s }
    if region_definition
      region = @page.regions.detect { |region| region.definition_id == region_definition.id }
      region && region.body.present?
    else
      false
    end
  end

  def yield_region(label)
    @page.check_template_support!
    region_definition = @region_definitions.find { |definition| definition.label == label.to_s }
    if region_definition
      region = @page.regions.find { |region| region.definition_id == region_definition.id }
      content_tag :div, region.body.html_safe, class: 'region' if region and region.body.present?
    else
      raise Template::RegionDefinition::NotFound.new(label, @page.template) if Rails.env.development?
    end
  end
  alias_method :render_region, :yield_region

  private
  def region_for_label(label, whiny = false)
    @page.check_template_support!
    region_definition = @region_definitions.find { |definition| definition.label == label.to_s }
    if region_definition
      region = @page.regions.find { |region| region.definition_id == region_definition.id }
    else
      raise Template::RegionDefinition::NotFound.new(label, @page.template) if whiny and Rails.env.development?
    end
  end
end