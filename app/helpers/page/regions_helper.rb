module Page::RegionsHelper
  def html_present?(content)
    content.present? && !content.in?(Page::Region::EMPTY_BODY_CONTENTS)
  end

  def region_content_for?(label)
    @page.check_template_support!
    definition = @region_definitions.find { |d| d.label == label.to_s }
    return false unless definition
    region = @page.regions.find { |r| r.definition_id == definition.id }
    region && html_present?(region.body)
  end

  def yield_region(label)
    @page.check_template_support!
    definition = @region_definitions.find { |d| d.label == label.to_s }
    if definition
      return unless region_content_for?(label)
      region = @page.regions.find do |r|
        r.definition_id == definition.id
      end
      content_tag :div, region.body.html_safe,
                  id: "#{label}_region", class: [
                    'region', "region-#{definition.region_type.dasherize}"]
    elsif Rails.env.development?
      fail Template::RegionDefinition::NotFound.new(label, @page.template)
    end
  end

  alias_method :render_region, :yield_region
end
