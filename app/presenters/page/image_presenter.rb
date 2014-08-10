class Page::ImagePresenter < Page::ApplicationPresenter
  presents :image_page


  # Facebook

  def facebook_uri
    page.metadata.fetch(:facebook_uri) { h.page_permalink_url(page.permalink, locale: nil) }
  end

  def facebook_like_button(options = {})
    h.facebook_like_button(facebook_uri, options)
  end

  def facebook_comments(options = {})
    h.facebook_comments(facebook_uri, options)
  end


  # Shops

  def shop_links
    h.content_tag :ul, class: 'shop-providers' do
      Page::Image.available_shop_providers.each do |name|
        if image_page.shop_urls[name].present?
          link = self.shop_link(name)
          h.concat h.content_tag(:li, link, class: ['shop-provider', name.to_s.dasherize])
        end
      end
    end
  end

  def shop_link(name)
    url = image_page.shop_urls[name]
    human_name = I18n.translate(name, scope: 'views.page/image.shops', default: name.to_s.humanize)
    h.link_to_if url.present?, human_name, url, target: '_blank'
  end

  Page::Image::SHOP_PROVIDERS.each do |name|
    class_eval <<-RUBY
      def #{name}_link
        self.shop_link(:#{name})
      end
    RUBY
  end
end