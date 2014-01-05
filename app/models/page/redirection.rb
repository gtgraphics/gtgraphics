class Page < ActiveRecord::Base
  class Redirection < ActiveRecord::Base
    include BatchTranslatable
    include PageEmbeddable

    belongs_to :destination_page, class_name: 'Page'

    translates :title, fallbacks_for_empty_translations: true

    validates :destination_page_id, presence: true, if: :internal?
    validates :destination_url, presence: true, url: true, if: :external?

    before_validation :clear_obsolete_destination_attribute
    before_validation :sanitize_destination_url

    acts_as_batch_translatable
    acts_as_page_embeddable

    def destination
      if external?
        destination_url
      else
        destination_page
      end
    end

    def internal?
      !external?
    end
    alias_method :internal, :internal?

    def internal=(internal)
      self.external = !internal
    end

    private
    def clear_obsolete_destination_attribute
      if external?
        self.destination_page = nil
      else
        self.destination_url = nil
      end
    end

    def sanitize_destination_url
      if destination_url.present? and destination_url !~ /\A(http|https):\/\//i
        self.destination_url = 'http://' + destination_url
      end
    end
  end
end