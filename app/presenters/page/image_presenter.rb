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

  def shop_provider_links
    h.content_tag :ul, class: 'shop-providers' do
      image_page.shop_providers.each_key do |name|
        link = self.shop_provider_link(name)
        h.concat h.content_tag(:li, link, class: ['shop-provider', name.to_s.dasherize])
      end
    end
  end

  def shop_provider_link(name)
    url = image_page.shop_providers[name]
    human_name = I18n.translate(name, scope: 'views.page/image.shops', default: name.to_s.humanize)
    h.link_to_if url.present?, human_name, url, target: '_blank'
  end

  %w(deviantart fineartprint mygall redbubble artflakes).each do |name|
    class_eval <<-RUBY
      def #{name}_link
        shop_provider_link :#{name}
      end

      def #{name}_url
        image_page.shop_providers[:#{name}]
      end
    RUBY
  end
end