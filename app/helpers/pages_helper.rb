module PagesHelper
  def concrete_page_types
    Page.creatable_embeddable_classes.sort_by { |klass| klass.model_name.human }
  end

  def render_page_content(content, options = {})
    liquify(content, with: @page.to_liquid.merge(
      'language' => translate(options[:locale], scope: :languages),
      'native_language' => translate(options[:locale], scope: :languages, locale: options[:locale])
    ))
  end
end