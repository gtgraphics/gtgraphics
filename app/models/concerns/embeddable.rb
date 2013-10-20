module Embeddable
  extend ActiveSupport::Concern

  included do
    has_one :page, as: :embeddable, dependent: :destroy
    
    delegate :slug, :path, :published?, :hidden?, to: :page
  end
end