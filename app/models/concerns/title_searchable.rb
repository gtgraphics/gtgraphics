module TitleSearchable
  extend ActiveSupport::Concern

  included do
    include Searchable

    acts_as_searchable_on :translations_title
  end
end
