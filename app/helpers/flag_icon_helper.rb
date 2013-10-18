module FlagIconHelper
  def flag_icon(locale, options = {})
    size = options.fetch(:size, 16)
    options = options.reverse_merge(alt: translate(locale, scope: :languages)).merge(width: size, height: size)
    options[:class] ||= ""
    options[:class] << " flag"
    options[:class].strip!
    image_tag("flags/#{size}/#{locale}.png", options)
  end
end