module Sluggable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_slug(*args)
      class_attribute :slug_attribute, :slug_options, instance_accessor: false
      options = args.extract_options!.assert_valid_keys(:param, :from, :if,
                                                        :unless, :on)
      self.slug_options = options.reverse_merge(param: true)
      self.slug_attribute = args.first || :slug

      composed_of slug_attribute, class_name: 'Slug',
                                  mapping: [slug_attribute, 'to_s'],
                                  constructor: :new, converter: :new,
                                  allow_nil: true

      include Extensions
    end

    def with_slug(*slugs)
      where(arel_table[slug_attribute].in(slugs.flatten))
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

    def obtain_slug
      source_attribute = self.class.slug_options[:from]
      return unless source_attribute
      source_proc = case source_attribute
                    when Proc then source_attribute
                    when Symbol
                      lambda do |object|
                        object.public_send(source_attribute)
                      end
                    else
                      fail ArgumentError, 'cannot infer slug from ' +
                                          source_attribute.class.name
                    end
      proc_args = [self].slice(0...source_proc.arity)
      instance_exec(*proc_args, &source_proc)
    end

    def set_slug
      source_attribute = self.class.slug_options[:from]
      return unless source_attribute
      send("#{self.class.slug_attribute}=", obtain_slug)
    end
  end
end
