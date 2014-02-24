Rails.application.config.to_prepare do
  # Liquid::Template.register_filter(LiquidExt::Filter::Text)
  Liquid::Template.register_tag('snippet', LiquidExt::Tag::Snippet)
end