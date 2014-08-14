class Import::GalleryPageParser
  URL_PATTERN = "http://www.gtgraphics.de/category/%{name}/%{page}"

  attr_reader :name, :documents, :default_document

  def initialize(name)
    @name = name
    @default_document = Nokogiri::HTML(open(self.url))
    @documents = 2.upto(self.pages_count).inject({}) do |documents_hash, page|
      documents_hash[page] = Nokogiri::HTML(open(self.url(page)))
      documents_hash
    end
    @documents[1] = @default_document
  end

  def url(page = 1)
    URL_PATTERN % { name: @name, page: page }
  end

  def pages_count
    default_document.css('#gtg-page-content .container_12:last a')[-2].text.to_i
  end

  def current_document
    documents[self.page]
  end

  def page_urls
    1.upto(pages_count).collect_concat do |page|
      documents.fetch(page).css('.content-top-pic').collect do |element|
        element.css('a').first[:href]
      end
    end
  end

  def page
    @page ||= 1
  end
  attr_writer :page
end