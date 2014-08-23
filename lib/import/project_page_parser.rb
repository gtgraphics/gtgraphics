class Import::ProjectPageParser < Import::LocalizedPageParser

  def url
    description_fragment
  end

  # TODO
  def asset_urls
    urls = default_document.css('.showcase-image-side img').collect do |element|
      element[:src]
    end
    if urls.empty?
      Array.wrap(default_document.css('.img-container img').first[:src])
    else
      urls
    end
  end
end