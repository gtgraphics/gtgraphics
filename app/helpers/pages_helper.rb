module PagesHelper
  def render_page_content(content, options = {})
    liquify(content, with: @page.to_liquid.merge(
      'language' => translate(options[:locale], scope: :languages),
      'native_language' => translate(options[:locale], scope: :languages, locale: options[:locale])
    ))
  end
end