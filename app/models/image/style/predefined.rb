class Image < ActiveRecord::Base
  class Style < ActiveRecord::Base
    class Predefined
      attr_reader :image, :style_name
      delegate :id, to: :image, prefix: true
      delegate :width, :height, to: :dimensions
      delegate :width, :height, to: :transformed_dimensions, prefix: :transformed

      def initialize(image, style_name)
        @image = image
        @style_name = style_name
      end

      def asset_url
        @image.asset_url(@style_name)
      end

      def asset_path
        @image.asset_path(@style_name)
      end

      def caption
        localized_style_name = I18n.translate(style_name, scope: 'image/style.predefined_names')
        I18n.translate('image/style.predefined_caption_format', dimensions: dimensions.to_s, style_name: localized_style_name)
      end

      def dimensions
        @image.predefined_style_dimensions[@style_name]
      end
      alias_method :transformed_dimensions, :dimensions

      def inspect
        "#<#{self.class.name} image_id: #{image_id.inspect}, style_name: #{style_name.inspect}>"
      end

      def type
        self.class.name
      end

      def to_param
        style_name
      end
    end
  end
end