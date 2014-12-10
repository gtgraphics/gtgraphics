module LoaderHelper
  def loader(options = {})
    content_tag :div, id: 'loader' do
      prepend_icon :circle, translate('helpers.loader.loading'), outline: true, style: :notch, fixed_width: true, spin: true
    end
  end
end