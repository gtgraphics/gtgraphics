module LoaderHelper
  def loader(options = {})
    options[:class] ||= ''
    options[:class] << ' loader'
    options[:class].strip!
    content_tag :div, options do
      prepend_icon(:refresh, translate('views.admin.loader.loading'), spin: true)
    end
  end
end