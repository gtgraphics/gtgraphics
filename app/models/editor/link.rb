class Editor::Link
  include ActiveModel::Model
  include Virtus.model

  attribute :caption, String
  attribute :external, Boolean, default: false
  attribute :page_id, Integer
  attribute :url, String
  attribute :target, String

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

  def to_html(template)
    href = internal? ? template.page_path(page) : url
    template.content_tag(:a, caption, href: href, target: target).html_safe
  end
end