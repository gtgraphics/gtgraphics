module RegionsHelper
  def render_region(label, options = {})
    raise Template::RegionDefinition::NotSupported.new(@page.template) unless @page.supports_regions?
    options.reverse_merge!(locale: @page_locale || I18n.locale, editing: try(:editing?) || false)
    if region_definition = @region_definitions.find { |definition| definition.label == label.to_s }
      if region = @page.regions.find_by(definition: region_definition)
        if options[:editing]
          # disable Globalize fallbacks in editor mode
          region_translation = region.translation_for(locale, false)
        else
          region_translation = Globalize.fallbacks(options[:locale]).collect { |locale| region.translation_for(locale, false) }.compact.first
        end
        if region_translation
          untranslated = region_translation.locale != options[:locale]
          html_lang = untranslated ? region_translation.locale : nil
          additional_css = untranslated ? 'untranslated' : nil
          content = render_page_content(region_translation.body, locale: options[:locale])
        end
      end
      html_options = { class: "region #{additional_css}".strip, lang: html_lang }
      if editing? and can?(:update, @page)
        html_options.merge!({ data: { region: label, url: admin_page_region_path(@page, label) } })
        content_tag :div, content, html_options
      elsif content
        content_tag :div, content, html_options
      end
    else
      raise Template::RegionDefinition::NotFound.new(label, @page.template) if Rails.env.development?
    end
  end
end