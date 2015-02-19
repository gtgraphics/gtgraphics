module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_searchable_on(*attributes)
      unless respond_to?(:searchable_attributes)
        class_attribute :searchable_attributes, instance_accessor: false
      end
      self.searchable_attributes = attributes
      extend Extensions
    end
  end

  module Extensions
    def search(query)
      if query.present?
        terms = query.to_s.split.uniq.map { |term| "%#{term}%" }
        search_attributes = searchable_attributes.collect do |attribute|
          "#{attribute}_matches_any"
        end
        search_attribute = search_attributes.join('_or_')
        ransack(search_attribute => terms).result
      else
        all
      end
    end
  end
end
