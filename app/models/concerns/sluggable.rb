module Sluggable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_slug(*args)
      class_attribute :slug_attribute, :slug_options, instance_accessor: false
      self.slug_options = args.extract_options!.reverse_merge(param: true)
      self.slug_attribute = args.first || :slug

      composed_of slug_attribute, mapping: [slug_attribute, 'to_s'], allow_nil: true, converter: :new

      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    def to_param
      if self.class.slug_options[:param]
        send(self.class.slug_attribute).to_s
      else
        super
      end
    end
  end
end