class Import::LocalizedPageParser
  AUTHORS_MAP = {
    'Taenaron' => 'Tobias Roetsch',
    'gucken' => 'Jeff Michelmann'
  }.freeze

  attr_reader :url, :documents, :default_document

  def initialize(url)
    @url = url
    @documents = I18n.available_locales.inject({}) do |documents_hash, locale|
      documents_hash[locale] = Nokogiri::HTML(open("#{@url}?setlang=#{locale}"))
      documents_hash
    end
    @default_document = @documents.fetch(I18n.default_locale)
  end

  def locale
    @locale ||= I18n.default_locale
  end
  attr_writer :locale

  def current_document
    documents.fetch(self.locale)
  end

  def with_locale(new_locale)
    previous_locale = self.locale
    self.locale = new_locale
    yield
    self.locale = previous_locale
  end

  def author
    author_str = default_document.css('.title-ct span:last').text.squish
    if author_str =~ /\A\(by (.*)\)\z/
      User.find_by_name(AUTHORS_MAP.fetch($1))
    else
      fail 'Author could not be extracted from document'
    end
  end

  def title
    current_document.css('.img-title').inner_text.squish
  end

  def description
    description_fragment.first.inner_html.squish
  end

  def description_fragment
    current_document.css('.image-box-content p')
  end
end
