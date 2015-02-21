class Image < ActiveRecord::Base
  module Resizable
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_resizable
        include Extensions
      end
    end

    module Extensions
      extend ActiveSupport::Concern

      included do
        with_options numericality: { only_integer: true, greater_than: 0 },
                     allow_blank: true, if: :resized? do |resizable|
          resizable.validates :resize_width
          resizable.validates :resize_height
        end

        before_validation :clear_resize_dimensions, if: :asset_changed?,
                                                    on: :update
        before_save :clear_resize_dimensions, unless: :resized?

        store_accessor :customization_options, :resized,
                       :resize_width, :resize_height
        alias_method :resized?, :resized

        include AccessorOverrides

        alias_method_chain :asset=, :resizing
      end

      module AccessorOverrides
        extend ActiveSupport::Concern

        included do
          %w(resize_width resize_height).each do |method|
            class_eval <<-RUBY
              def #{method}=(value)
                super(value.try(:to_i))
              end
            RUBY
          end
        end

        def resized=(resized)
          super(resized.to_b)
        end
      end

      def asset_with_resizing=(asset)
        clear_crop_area
        asset_without_resizing = asset
      end

      def resize_geometry
        return nil unless resized?
        resize_width = self.resize_width || '100%'
        resize_height = self.resize_height || '100%'
        "#{resize_width}x#{resize_height}!"
      end

      protected

      def clear_resize_dimensions
        self.resized = nil
        self.resize_width = nil
        self.resize_height = nil
      end
    end
  end
end
