module UniquelyTranslated
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_uniquely_translated(*scope_attributes)
      validates :locale, uniqueness: { scope: scope_attributes }, strict: true
    end
  end
end
