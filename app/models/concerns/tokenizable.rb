module Tokenizable
  extend ActiveSupport::Concern

  DEFAULT_TOKEN = ','

  module ClassMethods
    def acts_as_tokenizable(*methods)
      options = methods.extract_options!.reverse_merge(token: DEFAULT_TOKEN)
      methods.each do |method|
        method = method.to_sym
        if association = reflect_on_association(method)
          # Are we working on an association?
          raise 'association must be a one-to-many association to be used by tokenizer' unless association.collection?
          singular_association_name = method.to_s.singularize
          class_eval %{
            def #{singular_association_name}_tokens
              @#{singular_association_name}_tokens ||= #{singular_association_name}_ids.join('#{options[:token]}')
            end

            def #{singular_association_name}_tokens=(tokens)
              ids = tokens.split('#{options[:token]}').map(&:to_i).reject(&:zero?)
              self.#{singular_association_name}_ids = ids
              @#{singular_association_name}_tokens = ids.join('#{options[:token]}')
            end
          }
        elsif method_defined?(method)
          # Are we working on a plain old Ruby method?
          singular_method_name = method.to_s.singularize
          class_eval %{
            def #{singular_method_name}_tokens
              @#{singular_method_name}_tokens ||= #{method}.join('#{options[:token]}')
            end

            def #{singular_method_name}_tokens(tokens)
              self.#{method} = tokens.split('#{options[:token]}')
              @#{singular_method_name}_tokens = tokens
            end
          }
        else
          raise "Association or method #{self.name}##{method} is not defined"
        end
      end
    end
  end
end