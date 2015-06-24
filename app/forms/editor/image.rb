module Editor
  class Image < EditorForm
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
          model = image
        else
          model = style
        end
        model.asset.public.url
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
        if style_id.present?
          html_options[:data][:style_id] = style_id
        end
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
        self.style_id = nil if original_style?
      end
    end
  end
end
