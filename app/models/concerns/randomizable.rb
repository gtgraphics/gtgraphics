module Randomizable
  extend ActiveSupport::Concern

  module ClassMethods
    def shuffle
      unscoped.where(id: select(arel_table[:id])).order('RANDOM()')
    end

    def pick(amount)
      shuffle.limit(amount)
    end

    def sample
      shuffle.first
    end
  end
end