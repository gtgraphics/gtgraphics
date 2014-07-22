# == Schema Information
#
# Table name: images
#
#  id                    :integer          not null, primary key
#  asset                 :string(255)
#  content_type          :string(255)
#  file_size             :integer
#  asset_updated_at      :datetime
#  original_width        :integer
#  original_height       :integer
#  exif_data             :text
#  created_at            :datetime
#  updated_at            :datetime
#  author_id             :integer
#  customization_options :text
#  width                 :integer
#  height                :integer
#  original_filename     :string(255)
#  asset_token           :string(255)      not null
#

class Editor::Image < EditorActivity
  ALIGNMENTS = %w(left right top middle bottom).freeze

  embeds_one :image
  embeds_one :style, class_name: 'Image::Style'

  attribute :external, Boolean, default: false
  attribute :url, String
  attribute :alternative_text, String
  attribute :original_style, Boolean, default: true
  attribute :width, Integer
  attribute :height, Integer
  attribute :alignment, String

  validates :url, presence: true, if: :external?
  validates :image_id, presence: true, if: :internal?
  validates :width, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :height, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :alignment, inclusion: { in: ALIGNMENTS }, allow_blank: true

  after_initialize :set_defaults
  before_validation :sanitize_url_or_image

  def self.alignments
    ALIGNMENTS.inject({}) do |alignments_hash, alignment|
      alignments_hash.merge!(alignment => I18n.translate(alignment, scope: 'editor/image.alignments'))
    end
  end

  def internal?
    !external?
  end
  alias_method :internal, :internal?

  def image_src
    if external?
      url
    else
      if original_style?
        model = self.image
      else
        model = self.style
      end
      model.asset.custom.url
    end
  end

  def persisted?
    external? ? url.present? : image_id.present?
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
  def set_defaults
    if persisted?
      if internal? and image.nil?
        self.image_id = nil
        self.external = true
      end
    end
  end

  def sanitize_url_or_image
    if external?
      self.image_id = nil
      self.style_id = nil
      self.original_style = true
    else
      self.url = nil
    end
  end
end
