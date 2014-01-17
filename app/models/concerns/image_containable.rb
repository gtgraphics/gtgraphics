module ImageContainable
  extend ActiveSupport::Concern

  CONTENT_TYPES = [Mime::JPEG, Mime::GIF, Mime::PNG].freeze

  module ClassMethods
    def acts_as_image_containable(options = {})
      include AssetContainable
      acts_as_asset_containable(options)
      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    included do
      # validates_attachment :asset, presence: true, content_type: { content_type: CONTENT_TYPES }

      alias_attribute :original_width, :width
      alias_attribute :original_height, :height

      before_save :set_dimensions, if: :asset_changed?

      delegate :aspect_ratio, :pixels, to: :dimensions
    end

    module ClassMethods
      def content_types
        ImageContainable::CONTENT_TYPES
      end
    end

    def dimensions
      ImageDimensions.new(width, height)
    end

    def format
      mime_type.to_sym
    end

    def mime_type
      CONTENT_TYPES.find { |content_type| content_type == self.content_type }
    end

    private
    def set_dimensions
      geometry = Paperclip::Geometry.from_file(asset.queued_for_write[:original].path)
      self.width = geometry.width.to_i
      self.height = geometry.height.to_i
    end
  end
end