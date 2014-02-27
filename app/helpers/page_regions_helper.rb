module PageRegionsHelper
  def render_region(label, options = {})
    raise Template::RegionDefinition::NotSupported.new(@page.template) unless @page.supports_regions?
    options.reverse_merge!(locale: I18n.locale)
    if region_definition = @region_definitions.find { |definition| definition.label == label.to_s }
      if region = @page.regions.find_by(definition: region_definition)
        region_translation = Globalize.fallbacks(options[:locale]).collect { |locale| region.translation_for(locale, false) }.compact.first
        if region_translation
          untranslated = region_translation.locale != options[:locale]
          html_lang = untranslated ? region_translation.locale : nil
          additional_css = untranslated ? 'untranslated' : nil
          content = render_page_content(region_translation.body, locale: options[:locale])
        end
      end
      if editing? and can?(:update, @page)
        content_tag :div, content, class: "region well #{additional_css}".strip, lang: html_lang, data: { region: label, url: admin_page_region_path(@page, label) }
      elsif content
        content_tag :span, content, class: "region #{additional_css}".strip, lang: html_lang
      end
    else
      raise Template::RegionDefinition::NotFound.new(label, @page.template) if Rails.env.development?
    end
  end
end