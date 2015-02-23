class Import::ProjectPageParser < Import::LocalizedPageParser
  def project_title
    category_and_title.last
  end

  def project_type
    category_and_title.first
  end

  def url
    anchor = description_fragment.css('a[href]').first
    anchor[:href] if anchor
  end

  def asset_urls
    urls = default_document.css('.showcase-image-side img')
           .collect { |element| element[:src] }
    return urls if urls.any?
    Array.wrap(default_document.css('.img-container img').first[:src])
  end

  private

  def category_and_title
    if title =~ /(.*)\: (.*)/
      [$1, $2].map(&:squish)
    elsif title =~ /(.*) \- (.*)/
      [$1, $2].map(&:squish)
    else
      [nil, title.squish]
    end
  end
end
