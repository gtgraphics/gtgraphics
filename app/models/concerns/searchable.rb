module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_searchable_on(attribute)
      unless respond_to?(:searchable_attribute)
        class_attribute :searchable_attribute, instance_accessor: false
      end
      self.searchable_attribute = attribute
      extend Extensions
    end
  end

  module Extensions
    def search(query)
      if query.present?
        terms = query.to_s.split.uniq.map { |term| "%#{term}%" }
        ransack("#{self.searchable_attribute}_matches_any" => terms).result
      else
        all
      end
    end
  end
end