Rails.application.config.to_prepare do
  Liquid::Template.register_filter(LiquidExt::TextFilter)
end