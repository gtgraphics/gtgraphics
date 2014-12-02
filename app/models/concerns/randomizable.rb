module Randomizable
  extend ActiveSupport::Concern

  module ClassMethods
    def sample
      unscoped.where(id: select(arel_table[:id])).order('RANDOM()').first
    end
  end
end