xml.instruct! :xml, version: '1.0' 
xml.rss version: '2.0' do
  xml.channel do
    xml.title @page.title
    xml.description @page.meta_description
    xml.link page_permalink_url(@page)
    
    @image_pages.each do |image_page|
      xml.item do
        xml.title image_page.title
        xml.description image_page.embeddable.image
        xml.pubDate image_page.created_at.to_s(:rfc822)
        xml.link page_permalink_url(image_page)
        xml.guid page_permalink_url(image_page)
      end
    end
  end
end