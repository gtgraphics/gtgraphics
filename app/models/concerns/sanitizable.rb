module Sanitizable
  extend ActiveSupport::Concern

  module ClassMethods
    # sanitizes :content, with: [:strip_tags, :squish]
    # sanitizes :content do |content|
    #   content.squish.downcase
    # end
    def sanitizes(*attribute_names, &block)
      options = attribute_names.extract_options!
      options.assert_valid_keys(:with)
      options.reverse_merge!(with: block_given? ? block : :strip)
      if sanitizer = options[:with]
        if sanitizer.respond_to?(:call)
          sanitizer_proc = sanitizer
        else
          sanitizer_proc = lambda do |value|
            Array(sanitizer).inject(value) do |prev_value, method|
              if method.respond_to?(:call)
                method.call(prev_value)
              else
                prev_value.send(method)
              end
            end
          end
        end
        before_validation options.slice(:on) do
          attribute_names.each do |attribute_name|
            attribute_value = send(attribute_name)
            unless attribute_value.nil?
              send("#{attribute_name}=", sanitizer_proc.call(attribute_value))
            end
          end
        end
      end
    end
  end
end