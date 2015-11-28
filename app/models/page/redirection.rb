# == Schema Information
#
# Table name: redirection_pages
#
#  id                  :integer          not null, primary key
#  external            :boolean          default(FALSE), not null
#  destination_page_id :integer
#  destination_url     :string
#  permanent           :boolean          default(FALSE), not null
#

class Page < ActiveRecord::Base
  class Redirection < ActiveRecord::Base
    include Page::Concrete

    acts_as_concrete_page do |config|
      config.template_class_name = false
    end

    belongs_to :destination_page, class_name: 'Page', inverse_of: :redirections

    validates :destination_page_id, presence: true, if: :internal?
    validates :destination_url, presence: true, url: true, if: :external?
    validate :verify_destination_page_is_not_page, if: :internal?

    before_validation :clear_obsolete_destination_attribute
    before_validation :sanitize_destination_url

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
      if destination_url.present? && destination_url !~ /\A(http|https):\/\//i
        self.destination_url = 'http://' + destination_url
      end
    end

    def verify_destination_page_is_not_page
      return unless page == destination_page
      errors.add :destination_page_id, :self_reference
    end
  end
end
