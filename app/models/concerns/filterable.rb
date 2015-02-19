module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(*args)
      params = args.shift
      options = args.extract_options!
      filter_class = options.fetch(:with) { "#{self.name.pluralize}Filter" }.to_s.constantize
      filter_class.new(all, params)
    end
  end
end
