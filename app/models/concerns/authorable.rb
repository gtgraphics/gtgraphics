module Authorable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_authorable(*args)
      options = args.extract_options!
      name = args.first || :author
      options.reverse_merge!(column: :"#{name}_id", default_to_current_user: true)

      belongs_to name.to_sym, class_name: 'User', foreign_key: options[:column]

      if options[:default_to_current_user]
        before_validation do
          send("#{name}=", User.current) if send(options[:column]).nil?
        end
      end
    end
  end
end