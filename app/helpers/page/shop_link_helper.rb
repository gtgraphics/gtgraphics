module Page::ShopLinkHelper
  def shop_icon_link(name, url)
    caption = translate(name, scope: 'views.page/image.shops',
                              default: name.to_s.titleize)
    image_path = "shops/shop-150/#{name}.png"
    content_tag :div, class: 'icon-menu-item' do
      link_to url, target: '_blank', class: 'icon-menu-link',
                   title: caption, alt: caption,
                   data: { toggle: 'tooltip', placement: 'top' } do
        concat image_tag(image_path, class: 'img-responsive')
        concat content_tag(:span, caption, class: 'sr-only')
      end
    end
  end
end
