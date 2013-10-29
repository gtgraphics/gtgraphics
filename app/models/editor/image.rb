class Editor::Image
  include ActiveModel::Model
  include Virtus.model

  attribute :external, Boolean, default: false
  attribute :image_id, Integer
  attribute :url, String
  attribute :alternative_text, String
  attribute :editing, Boolean, default: false

  validates :url, presence: true, if: :external?
  validates :image_id, presence: true, if: :internal?

  def internal?
    !external?
  end

  alias_method :internal, :internal?

  def internal=(internal)
    self.external = !internal
  end

  def image
    @image ||= Page.find(image_id)
  end

  def image=(image)
    self.image_id = image.id
    @image = image
  end

  def to_html(template)
    src = internal? ? template.page_path(page) : url
    template.tag(:img, src: src, alt: alternative_text || '').html_safe
  end
end