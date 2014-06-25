module PagesHelper
  def concrete_page_types
    Page.creatable_embeddable_classes.sort_by { |klass| klass.model_name.human }
  end

  def render_page_content(content, options = {})
    locale = options[:locale]
    liquify(content, with: @page.to_liquid.merge(
      'language' => translate(locale, scope: :languages),
      'native_language' => translate(locale, scope: :languages, locale: locale)
    ))
  end
end