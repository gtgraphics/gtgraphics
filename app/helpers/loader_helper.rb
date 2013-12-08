module LoaderHelper
  def loader(options = {})
    size = options.delete(:size)
    options[:class] ||= ''
    options[:class] << ' loader'
    options[:class] << " loader-#{size.to_s.dasherize}" if size.present?
    options[:class].strip!
    content_tag :div, options do
      prepend_icon(:refresh, translate('views.admin.loader.loading'), spin: true)
    end
  end
end