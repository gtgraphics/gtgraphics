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