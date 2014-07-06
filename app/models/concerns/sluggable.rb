module Sluggable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_slug(*args)
      class_attribute :slug_attribute, :slug_options, instance_accessor: false
      options = args.extract_options!.assert_valid_keys(:param, :from, :if, :unless, :on)
      self.slug_options = options.reverse_merge(param: true)
      self.slug_attribute = args.first || :slug

      composed_of slug_attribute, mapping: [slug_attribute, 'to_s'], allow_nil: true, converter: :new

      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    included do
      before_validation :set_slug, slug_options.slice(:if, :unless, :on)
    end

    def to_param
      if self.class.slug_options[:param]
        send(self.class.slug_attribute).to_s
      else
        super
      end
    end

    def generate_slug
      if source_attribute = self.class.slug_options[:from]
        source_proc = source_attribute.to_proc
        proc_args = [self].slice(0...source_proc.arity)
        self.instance_exec(*proc_args, &source_proc)
      end
    end

    private
    def set_slug
      if source_attribute = self.class.slug_options[:from]
        self.send("#{self.class.slug_attribute}=", self.generate_slug)
      end
    end
  end
end