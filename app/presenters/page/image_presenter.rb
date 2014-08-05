class Page::ImagePresenter < ApplicationPresenter
  presents :image_page

  delegate :page, to: :image_page

  def facebook_uri
    page.metadata.fetch(:facebook_uri) { h.page_permalink_url(page.permalink, locale: nil) }
  end

  def facebook_like_button(options = {})
    h.facebook_like_button(self.facebook_uri, options)
  end

  def facebook_comments(options = {})
    h.facebook_comments(self.facebook_uri, options)
  end

  %w(deviantart fineartprint mygall redbubble artflakes).each do |name|
    class_eval <<-RUBY
      def #{name}_link
        h.link_to I18n.translate('views.page/image.shops.#{name}'), #{name}_url, target: '_blank' if #{name}_url.present?
      end

      def #{name}_url
        page.metadata[:#{name}_url]
      end
    RUBY
  end
end