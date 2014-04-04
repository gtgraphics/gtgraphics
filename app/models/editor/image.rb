# == Schema Information
#
# Table name: images
#
#  id                    :integer          not null, primary key
#  asset_file_name       :string(255)
#  asset_content_type    :string(255)
#  asset_file_size       :integer
#  asset_updated_at      :datetime
#  width                 :integer
#  height                :integer
#  exif_data             :text
#  created_at            :datetime
#  updated_at            :datetime
#  author_id             :integer
#  customization_options :text
#  transformed_width     :integer
#  transformed_height    :integer
#

class Editor::Image < EditorActivity
  ALIGNMENTS = %w(left right top middle bottom).freeze
  STYLE_SOURCES = %w(original predefined custom).freeze

  embeds_one :image, class_name: '::Image'
  embeds_one :style, class_name: '::Image::Style'

  attribute :external, Boolean, default: false
  attribute :style_source, String, default: STYLE_SOURCES.first
  attribute :style_name, String
  attribute :url, String
  attribute :alternative_text, String
  attribute :width, Integer
  attribute :height, Integer
  attribute :alignment, String

  validates :url, presence: true, if: :external?
  validates :image_id, presence: true, if: :internal?
  validates :width, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :height, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :alignment, inclusion: { in: ALIGNMENTS }, allow_blank: true
  validates :style_id, presence: true, if: [:internal?, :custom_style?]
  validates :style_name, presence: true, inclusion: { in: ->(image) { ::Image.style_names.keys } }, if: [:internal?, :predefined_style?]

  before_validation :sanitize_image_id_and_url
  before_validation :sanitize_style

  class << self
    def alignments
      ALIGNMENTS.inject({}) do |alignments_hash, alignment|
        alignments_hash.merge!(alignment => I18n.translate(alignment, scope: 'editor/image.alignments'))
      end
    end

    def style_sources
      STYLE_SOURCES.inject({}) do |style_sources_hash, style_source|
        style_sources_hash.merge!(style_source => I18n.translate(style_source, scope: 'editor/image.style_sources'))
      end
    end
  end

  def custom_style?
    style_source == 'custom'
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
      if custom_style?
        style.asset_url
      else
        image.asset_url(style_name.presence || :transformed)
      end
    end
  end

  def predefined_style?
    style_source == 'predefined'
  end

  def to_html
    html_options = { src: image_src, width: width, height: height }
    html_options[:alt] = alternative_text || ''
    html_options[:align] = alignment.presence
    if internal?
      html_options[:data] = { image_id: image_id, style_source: style_source,
                              style_name: style_name.presence, style_id: style_id }
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

  def sanitize_style
    if external?
      self.style_source = nil
      self.style_id = nil
      self.style_name = nil
    else
      if predefined_style?
        self.style_id = nil
      elsif custom_style?
        self.style_name = nil
      else
        self.style_id = nil
        self.style_name = nil
      end
    end
  end
end
