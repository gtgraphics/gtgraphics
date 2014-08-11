class Page::ImagePresenter < Page::ApplicationPresenter
  presents :image_page


  # Facebook Integration

  def facebook_like_button(options = {})
    h.facebook_like_button(page.social_uri, options)
  end

  def facebook_comments(options = {})
    h.facebook_comments(page.social_uri, options)
  end

  def page
    present object.page # Eager loading Bug
  end

  # Shops

  def shop_links
    h.content_tag :ul, class: 'shop-providers' do
      Page::Image.available_shop_providers.each do |name|
        if image_page.shop_urls[name].present?
          h.concat h.content_tag(:li, self.shop_link(name), class: 'shop-provider')
        end
      end
    end
  end

  def shop_icon(name, options = {})
    options = options.reverse_merge(size: 16)
    size = options[:size]
    css = "shop shop-#{size} shop-#{size}-#{name.to_s.dasherize}"
    css << " shop-fw" if options[:fixed_width]
    h.content_tag :i, nil, class: css
  end

  def shop_link(name)
    url = image_page.shop_urls[name]
    human_name = I18n.translate(name, scope: 'views.page/image.shops', default: name.to_s.humanize)

    h.link_to url, target: '_blank' do
      h.concat shop_icon(name)
      h.concat h.content_tag(:span, human_name, class: 'caption')
    end
  end

  Page::Image::SHOP_PROVIDERS.each do |name|
    class_eval <<-RUBY
      def #{name}_link
        self.shop_link(:#{name})
      end
    RUBY
  end
end
