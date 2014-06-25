# == Schema Information
#
# Table name: project_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#  client_name :string(255)
#  client_url  :string(255)
#  released_on :date
#

class Page < ActiveRecord::Base
  class Project < ActiveRecord::Base
    include Page::Concrete

    acts_as_concrete_page

    translates :name, :description, fallbacks_for_empty_translations: true

    validates :client_name, presence: true
    validates :client_url, url: true, allow_blank: true

    after_initialize :set_default_release_date, if: -> { new_record? and released_on.blank? }

    private
    def set_default_release_date
      self.released_on = Date.today
    end
  end
end
