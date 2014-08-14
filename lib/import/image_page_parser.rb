class Import::ImagePageParser < Import::LocalizedPageParser
  def title
    current_document.css('.img-title').inner_text.squish
  end

  def description
    current_document.css('.image-box-content p').first.inner_html.squish
  end

  def asset_url
    default_document.css('.img-container img').first[:src]
  end

  def variant_asset_urls
    default_document.css('.image-box-content .grid_3 p .home-num-sign').collect { |anchor| anchor[:href] }
  end

  def hits_count
    hits_text = default_document.css('.image-box-content .grid_3 .zoom-ct').inner_text.squish
    if hits_text =~ /\AViews\: (.*)\z/
      $1.to_i
    else
      0
    end
  end

  def shop_url(key)
    element = default_document.css(".print-#{key}").first
    element['href'].presence if element
  end
end