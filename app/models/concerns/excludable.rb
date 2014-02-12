module Excludable
  extend ActiveSupport::Concern

  module ClassMethods
    def without(records)
      record_ids = Array(records).select(&:persisted?).map(&:id)
      if record_ids.any?
        where.not(id: record_ids.one? ? record_ids.first : record_ids)
      else
        all
      end
    end
  end
end