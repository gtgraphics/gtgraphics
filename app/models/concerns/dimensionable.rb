module Dimensionable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_dimensions(*args)
      options = args.extract_options!.assert_valid_keys(:from)
      options = options.reverse_merge(from: [:width, :height])
      
      attribute = args.first || :dimensions
      width_column, height_column = options.fetch(:from)

      composed_of attribute, class_name: 'ImageDimensions',
                             mapping: [[width_column, 'width'], [height_column, 'height']],
                             allow_nil: true, constructor: :parse, converter: :parse
    end
  end
end