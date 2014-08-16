module TitleSearchable
  extend ActiveSupport::Concern

  module ClassMethods
    def search(query)
      if query.present?
        terms = query.to_s.split.uniq.map { |term| "%#{term}%" }
        ransack(translations_title_matches_any: terms).result
      else
        all
      end
    end
  end
end