module Page::RegionsHelper
  def region_content_for?(label)
    @page.check_template_support!
    region_definition = @region_definitions.find do |definition|
      definition.label == label.to_s
    end
    return false unless region_definition
    region = @page.regions.find do |r|
      r.definition_id == region_definition.id
    end
    region && region.body && strip_tags(region.body).present?
  end

  def yield_region(label)
    @page.check_template_support!
    region_definition = @region_definitions.find do |definition|
      definition.label == label.to_s
    end
    if region_definition
      return unless region_content_for?(label)
      region = @page.regions.find do |r|
        r.definition_id == region_definition.id
      end
      content_tag :div, region.body.html_safe, class: 'region'
    else
      if Rails.env.development?
        fail Template::RegionDefinition::NotFound.new(label, @page.template)
      end
    end
  end
  alias_method :render_region, :yield_region

  private

  def region_for_label(label, whiny = false)
    @page.check_template_support!
    region_definition = @region_definitions.find do |definition|
      definition.label == label.to_s
    end
    if region_definition
      region = @page.regions.find do |r|
        r.definition_id == region_definition.id
      end
    else
      if whiny && Rails.env.development?
        fail Template::RegionDefinition::NotFound.new(label, @page.template)
      end
    end
  end
end
