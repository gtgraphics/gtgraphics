module Embeddable
  extend ActiveSupport::Concern

  included do
    has_one :page, as: :embeddable, dependent: :destroy
    
    delegate :slug, :path, :published?, :hidden?, to: :page, allow_nil: true
  end

  module ClassMethods
    def bound_to_page?
      @bound_to_page ||= false
    end

    def bound_to_page=(flag)
      @bound_to_page = flag
    end
  end
end