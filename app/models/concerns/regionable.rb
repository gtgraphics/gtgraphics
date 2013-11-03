module Regionable
  extend ActiveSupport::Concern

  included do
    has_many :regions, as: :regionable, dependent: :destroy

    accepts_nested_attributes_for :regions, allow_destroy: true
  end
end