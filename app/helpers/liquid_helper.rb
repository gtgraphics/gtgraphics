module LiquidHelper
  def liquify(*args, &block)
    options = args.extract_options!
    content = block_given? ? capture(&block) : args.first
    options.assert_valid_keys(:with, :filters)
    object_or_attributes = options.fetch(:with, {})
    filters = Array(options[:filters])
    if object_or_attributes.respond_to?(:to_liquid)
      attributes = object_or_attributes.to_liquid
      attributes.deep_stringify_keys!
    end
    template = Liquid::Template.parse(content)
    template.render(attributes, filters: filters).html_safe
  end
end