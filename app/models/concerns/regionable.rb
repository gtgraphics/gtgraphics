module Regionable
  extend ActiveSupport::Concern

  included do
    has_many :regions, dependent: :destroy
  end
end