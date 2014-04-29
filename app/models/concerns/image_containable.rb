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
      include Dimensionable

      alias_attribute :original_width, :width
      alias_attribute :original_height, :height

      before_save :set_dimensions, if: :asset_changed?

      delegate :aspect_ratio, :pixels, to: :dimensions

      has_dimensions :dimensions, from: [:width, :height]      
    end

    module ClassMethods
      def content_types
        ImageContainable::CONTENT_TYPES
      end
    end

    def format
      mime_type.to_sym
    end

    def mime_type
      CONTENT_TYPES.find { |content_type| content_type == self.content_type }
    end

    private
    def set_dimensions
      self.dimensions = Paperclip::Geometry.from_file(asset.queued_for_write[:original].path)
    end
  end
end