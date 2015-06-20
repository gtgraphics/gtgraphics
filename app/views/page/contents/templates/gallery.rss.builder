xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title @page.title
    xml.description @page.meta_description
    xml.link page_permalink_url(id: @page.permalink)

    @image_pages.each do |image_page|
      xml.item do
        xml.title image_page.title
        xml.description image_page.embeddable.image.description
        xml.pubDate image_page.created_at.to_s(:rfc822)
        xml.link page_permalink_url(id: image_page.permalink)
        xml.guid page_permalink_url(id: image_page.permalink)
      end
    end
  end
end
