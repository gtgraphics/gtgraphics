module FlagIconHelper
  def flag_icon(locale, options = {})
    size = options.fetch(:size, 16)
    image_tag("flags/#{size}/#{locale}.png", width: size, height: size, alt: translate(locale, scope: :languages))
  end
end