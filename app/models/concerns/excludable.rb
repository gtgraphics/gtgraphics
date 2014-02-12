module Excludable
  extend ActiveSupport::Concern

  module ClassMethods
    def without(records)
      record_ids = Array(records).select(&:persisted?).map(&:id)
      if record_ids.any?
        where.not(id: record_ids.many? ? record_ids : record_ids.first)
      else
        all
      end
    end
  end
end