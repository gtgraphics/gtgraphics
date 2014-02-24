class LiquidExt::Tag::Snippet < Liquid::Tag
  attr_reader :snippet_id

  def initialize(tag_name, snippet_id, tokens)
     super
     @snippet_id = snippet_id
  end

  def render(context)
    snippet.body.html_safe if snippet
  end

  private
  def snippet
    @snippet ||= ::Snippet.find_by(id: snippet_id)
  end
end