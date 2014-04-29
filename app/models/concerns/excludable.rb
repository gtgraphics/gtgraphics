module Excludable
  extend ActiveSupport::Concern

  module ClassMethods
    def without(*records_or_ids)
      record_ids = records_or_ids.flat_map do |record_or_id|
        if record_or_id.is_a?(self.class)
          record_or_id.send(self.primary_key)
        else
          record_or_id
        end
      end.reject(&:blank?)
      if record_ids.any?
        where.not(self.primary_key.to_sym => record_ids.many? ? record_ids : record_ids.first)
      else
        all
      end
    end
  end
end