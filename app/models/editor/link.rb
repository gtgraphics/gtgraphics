class Editor::Link < EditorActivity
  include Rails.application.routes.url_helpers
  include RouteHelper

  TARGETS = %w(_blank _top).freeze

  embeds_one :page

  attribute :content, String
  attribute :external, Boolean, default: false
  attribute :page_id, Integer
  attribute :locale, Symbol
  attribute :url, String
  attribute :target, String

  validates :url, presence: true, if: :external?
  validates :page_id, presence: true, if: :internal?

  after_initialize :check_page_existence, if: :internal?

  def self.targets
    TARGETS.inject({ '' => I18n.translate('editor/link.targets.self') }) do |targets, target|
      targets.merge!(target => I18n.translate(target, scope: 'editor/link.targets'))
    end
  end

  def internal?
    !external?
  end
  alias_method :internal, :internal?

  def persisted?
    external? ? url.present? : page_id.present?
  end

  def to_html
    href = external? ? url : page_path(page, locale: locale)
    options = { href: href }
    options[:target] = target if target.present?
    if internal? and page_id.present?
      data = { page_id: page_id }
      if locale.present?
        data[:locale] = locale 
        options[:hreflang] = locale
      end
      options[:data] = data
      content = page.title(locale)
    else
      content = url
    end
    content = self.content.presence || content
    content_tag(:a, content.html_safe, options).html_safe
  end

  private
  def check_page_existence
    if page.nil?
      self.page_id = nil
      self.external = true
    end
  end
end