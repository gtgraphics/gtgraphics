xml.instruct!
xml.sitemapindex xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  @sitemaps.each do |sitemap|
    xml.sitemap do
      xml.loc sitemap_url(page: sitemap.page)
      xml.lastmod sitemap.updated_at.iso8601
    end
  end
end