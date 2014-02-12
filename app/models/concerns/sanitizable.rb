module Sanitizable
  extend ActiveSupport::Concern

  module ClassMethods
    # sanitizes :content, with: :squish
    # sanitizes :content do |content|
    #   content.squish.downcase
    # end
    def sanitizes(*attribute_names, &block)
      options = attribute_names.extract_options!
      options.assert_valid_keys(:with)
      options.reverse_merge!(with: block_given? ? block : :strip)
      if sanitizer = options[:with]
        unless sanitizer.respond_to?(:call)
          sanitizer = ->(value) { Array(sanitizer).inject(value) { |prev_value, method| prev_value.send(method) } }
        end
        before_validation options.slice(:on) do
          attribute_names.each do |attribute_name|
            attribute_value = send(attribute_name)
            send("#{attribute_name}=", sanitizer.call(attribute_value)) unless attribute_value.nil?
          end
        end
      end
    end
  end
end