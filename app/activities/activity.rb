module Activity
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include Virtus.model
  end

  module ClassMethods
    def perform(attributes = {})
      new(attributes).tap(&:perform)
    end
  end

  def perform
  end
end