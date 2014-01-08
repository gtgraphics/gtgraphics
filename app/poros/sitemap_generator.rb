class SitemapGenerator
  require 'builder'

  include Singleton
  include Rails.application.routes.url_helpers
  include RouteHelper

  HOST = 'gtgraphics.de'
  SITEMAP_PATH = "#{Rails.root}/public/sitemap.xml"

  def generate
    return false unless Page.exists?
    max_page_depth = Page.maximum(:depth).next
    File.open(SITEMAP_PATH, 'wb') do |file|
      xml = Builder::XmlMarkup.new(indent: 2, target: file)
      xml.instruct!
      xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9', 'xmlns:xhtml' => 'http://www.w3.org/1999/xhtml' do
        Page.published.includes(:translations).find_each(batch_size: 50) do |page|
          if page.root?
            xml.url do
              xml.comment! "Root"
              xml.loc root_url(host: HOST)
              xml.lastmod page.updated_at.iso8601
              xml.changefreq 'daily'
              xml.priority 1.0
              page.translations.each do |page_translation|
                xml.xhtml :link, rel: 'alternate',
                                 href: page_url(page, locale: page_translation.locale, host: HOST),
                                 hreflang: page_translation.locale
              end
            end
          end

          page.translations.each do |page_translation|
            xml.url do
              xml.comment! "#{page_translation.title} (#{page_translation.locale})"
              xml.loc page_url(page, locale: page_translation.locale, host: HOST)
              xml.lastmod page.updated_at.iso8601
              xml.changefreq 'daily'
              xml.priority (1 - (page.depth) / (max_page_depth.to_f)).round(3)
              page.translations.each do |page_translation|
                xml.xhtml :link, rel: 'alternate',
                                 href: page_url(page, locale: page_translation.locale, host: HOST),
                                 hreflang: page_translation.locale
              end
            end
          end
        end
      end
    end
    true
  end
end