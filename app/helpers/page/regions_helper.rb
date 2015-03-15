module Page::RegionsHelper
  def html_present?(content)
    content.present? && !content.in?(Page::Region::EMPTY_BODY_CONTENTS)
  end

  def region_content_for?(label)
    !yield_region(label).nil?
  rescue Template::RegionDefinition::NotFound
    false
  end

  def yield_region(label)
    @page.check_template_support!
    definition = @region_definitions.find { |d| d.label == label.to_s }
    return if definition.nil?
    region = @page.regions.find { |r| r.definition_id == definition.id }
    body = region.body.html_safe
    body = nil unless html_present?(body)
    content_tag :div, body,
                id: "#{label}_region",
                class: ['region', "region-#{definition.region_type.dasherize}"]
  end

  alias_method :render_region, :yield_region
end
