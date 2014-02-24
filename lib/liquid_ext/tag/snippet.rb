class LiquidExt::Tag::Snippet < Liquid::Tag
  attr_reader :snippet_id

  def initialize(tag_name, snippet_id, tokens)
     super
     @snippet_id = snippet_id
  end

  def render(context)
    if snippet
      template = Liquid::Template.parse(snippet.body)
      attributes = snippet.to_liquid.merge(
        'language' => I18n.translate(I18n.locale, scope: :languages),
        'native_language' => I18n.translate(I18n.locale, scope: :languages, locale: I18n.locale)
      )
      template.render(attributes).html_safe
    end
  end

  private
  def snippet
    @snippet ||= ::Snippet.find_by(id: snippet_id)
  end
end