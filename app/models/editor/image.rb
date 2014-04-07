# == Schema Information
#
# Table name: images
#
#  id                          :integer          not null, primary key
#  asset_file_name             :string(255)
#  asset_content_type          :string(255)
#  asset_file_size             :integer
#  asset_updated_at            :datetime
#  width                       :integer
#  height                      :integer
#  exif_data                   :text
#  created_at                  :datetime
#  updated_at                  :datetime
#  author_id                   :integer
#  customization_options       :text
#  transformed_width           :integer
#  transformed_height          :integer
#  predefined_style_dimensions :text
#

class Editor::Image < EditorActivity
  ALIGNMENTS = %w(left right top middle bottom).freeze

  embeds_one :image, class_name: '::Image'

  attribute :external, Boolean, default: false
  attribute :original_style, Boolean, default: true
  attribute :style, String
  attribute :url, String
  attribute :alternative_text, String
  attribute :width, Integer
  attribute :height, Integer
  attribute :alignment, String

  validates :url, presence: true, if: :external?
  validates :image_id, presence: true, if: :internal?
  validates :style, presence: true, if: -> { !original_style? }
  validates :width, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :height, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :alignment, inclusion: { in: ALIGNMENTS }, allow_blank: true

  before_validation :sanitize_image_id_and_url

  class << self
    def alignments
      ALIGNMENTS.inject({}) do |alignments_hash, alignment|
        alignments_hash.merge!(alignment => I18n.translate(alignment, scope: 'editor/image.alignments'))
      end
    end
  end

  def custom_style?
    !predefined_style?
  end

  def internal?
    !external?
  end
  alias_method :internal, :internal?

  def internal=(internal)
    self.external = !internal
  end

  def image_src
    if external?
      url
    else
      if original_style?
        image.asset_url
      else
        image.styles.find { |s| custom_style? ? s.id == style.to_i : s.style_name.to_s == style }.asset_url
      end
    end
  end

  def predefined_style?
    Image::STYLES.keys.map(&:to_s).include?(style)
  end

  def to_html
    html_options = { src: image_src, width: width, height: height }
    html_options[:alt] = alternative_text || ''
    html_options[:align] = alignment.presence
    if internal?
      html_options[:data] = { image_id: image_id }
      html_options[:data][:style] = style unless original_style? and style.blank?
    end
    tag(:img, html_options).html_safe
  end

  private
  def sanitize_image_id_and_url
    if external?
      self.image_id = nil
    else
      self.url = nil
    end
  end
end
