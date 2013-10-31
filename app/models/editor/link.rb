class Editor::Link
  include ActiveModel::Model
  include Virtus.model

  attribute :caption, String
  attribute :external, Boolean, default: false
  attribute :page_id, Integer
  attribute :locale, Symbol
  attribute :url, String
  attribute :target, String
  attribute :persisted, Boolean, default: false

  validates :caption, presence: true
  validates :url, presence: true, if: :external?
  validates :page_id, presence: true, if: :internal?

  def internal?
    !external?
  end

  alias_method :internal, :internal?

  def internal=(internal)
    self.external = !internal
  end

  def page
    @page ||= Page.find(page_id)
  end

  def page=(page)
    self.page_id = page.id
    @page = page
  end

  def self.from_html(html)
    fragment = Nokogiri::HTML::DocumentFragment.parse(html)
    new(caption: fragment.text).tap do |instance|
      anchor = fragment.css('a')
      if anchor.present? and url = anchor.attribute('href').to_s and url.present?
        instance.persisted = true
        route = Rails.application.routes.recognize_path(url) rescue nil
        uri = URI.parse(url) rescue nil
        if uri.present? and uri.relative? and route.present? and route.key?(:id)
          if page = Page.find_by(path: route[:id])
            instance.page = page
            instance.locale = route[:locale] if I18n.available_locales.map(&:to_s).include?(route[:locale])
            instance.external = false
          end
        else
          instance.external = true
          instance.url = uri.to_s
        end
      else
        instance.persisted = false
      end
    end
  end

  def to_html(template)
    href = external? ? url : template.page_path(page, locale: locale)
    options = { href: href }
    options[:target] = target if target.present?
    if internal? and page_id.present?
      data = { page_id: page_id }
      data[:locale] = locale if locale.present?
      options[:data] = data
    end
    template.content_tag(:a, caption, options).html_safe
  end
end